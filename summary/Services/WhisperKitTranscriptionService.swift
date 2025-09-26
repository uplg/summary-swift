//
//  WhisperKitTranscriptionService.swift
//  summary
//

import Foundation
import WhisperKit
import AVFoundation
import Combine

@MainActor
class WhisperKitTranscriptionService: ObservableObject {
    @Published var isTranscribing: Bool = false
    @Published var progress: Double = 0.0
    @Published var errorMessage: String? = nil
    
    private var whisperKit: WhisperKit?
    private let statusService: ModelStatusService
    
    init(statusService: ModelStatusService) {
        self.statusService = statusService
        Task {
            await initializeWhisperKit()
        }
    }
    
    private func initializeWhisperKit() async {
        do {
            statusService.updateWhisperKitStatus(.loading)
            
            whisperKit = try await WhisperKit()
            print("✅ WhisperKit initialized successfully")
            statusService.updateWhisperKitStatus(.loaded)
        } catch {
            print("❌ Failed to initialize WhisperKit: \(error)")
            let errorMessage = "WhisperKit initialization error: \(error.localizedDescription)"
            self.errorMessage = errorMessage
            statusService.updateWhisperKitStatus(.error(errorMessage))
        }
    }
    
    func transcribeAudio(from audioURL: URL) async throws -> String {
        guard let whisperKit = whisperKit else {
            throw TranscriptionError.whisperKitNotInitialized
        }
        
        isTranscribing = true
        progress = 0.0
        errorMessage = nil
        
        defer {
            isTranscribing = false
            progress = 0.0
        }
        
        do {
            let processedAudioURL = try await preprocessAudio(audioURL)
            
            progress = 0.3
            
            let result = try await whisperKit.transcribe(audioPath: processedAudioURL.path)
            
            progress = 0.9
            
            guard let transcriptionText = result.first?.text, !transcriptionText.isEmpty else {
                throw TranscriptionError.emptyTranscription
            }
            
            progress = 1.0
            
            if processedAudioURL != audioURL {
                try? FileManager.default.removeItem(at: processedAudioURL)
            }
            
            return transcriptionText.trimmingCharacters(in: .whitespacesAndNewlines)
            
        } catch {
            print("❌ Transcription failed: \(error)")
            errorMessage = "Transcription error: \(error.localizedDescription)"
            throw error
        }
    }
    
    private func preprocessAudio(_ audioURL: URL) async throws -> URL {
        let fileExtension = audioURL.pathExtension.lowercased()
        if ["wav", "mp3", "m4a", "flac"].contains(fileExtension) {
            return audioURL
        }
        
        return try await convertAudioToM4A(audioURL)
    }
    
    private func convertAudioToM4A(_ inputURL: URL) async throws -> URL {
        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("m4a")
        
        if FileManager.default.fileExists(atPath: outputURL.path) {
            try FileManager.default.removeItem(at: outputURL)
        }
        
        let asset = AVURLAsset(url: inputURL)
        
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) else {
            throw TranscriptionError.audioConversionFailed
        }
        
        try await exportSession.export(to: outputURL, as: .m4a)
        return outputURL
    }
}

enum TranscriptionError: LocalizedError {
    case whisperKitNotInitialized
    case emptyTranscription
    case audioConversionFailed
    case unsupportedAudioFormat
    
    var errorDescription: String? {
        switch self {
        case .whisperKitNotInitialized:
            return "WhisperKit is not initialized"
        case .emptyTranscription:
            return "Transcription is empty"
        case .audioConversionFailed:
            return "Audio conversion failed"
        case .unsupportedAudioFormat:
            return "Unsupported audio format"
        }
    }
}
