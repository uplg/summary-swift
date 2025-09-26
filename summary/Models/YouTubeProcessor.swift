//
//  YouTubeProcessor.swift
//  summary
//

import Foundation
import SwiftData
import Combine

@MainActor
class YouTubeProcessor: ObservableObject {
    @Published var isProcessing = false
    @Published var currentStatus = "Waiting..."
    @Published var progress: Double = 0.0
    @Published var errorMessage: String?
    @Published var modelDownloadProgress: Double = 0.0
    @Published var isModelDownloading = false
    
    private let modelContext: ModelContext
    private let youtubeExtractor = YouTubeExtractor()
    private let audioDownloader = AudioDownloader()
    private let statusService = ModelStatusService()
    private let whisperKitService: WhisperKitTranscriptionService
    private let summaryService: MLXSummaryService
    private var cancellables = Set<AnyCancellable>()
    
    private let cacheManager = CacheManager.shared
    
    var modelStatusService: ModelStatusService {
        return statusService
    }
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        
        self.whisperKitService = WhisperKitTranscriptionService(statusService: statusService)
        self.summaryService = MLXSummaryService(statusService: statusService)
        cacheManager.cleanOldCache()
        
        summaryService.$downloadProgress
            .receive(on: DispatchQueue.main)
            .sink { [weak self] progress in
                self?.updateModelDownloadProgress(progress)
            }
            .store(in: &cancellables)
        
        summaryService.$isModelLoaded
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoaded in
                if isLoaded {
                    self?.isModelDownloading = false
                    self?.modelDownloadProgress = 1.0
                }
            }
            .store(in: &cancellables)
    }
    
    private func updateModelDownloadProgress(_ progress: Progress) {
        if progress.totalUnitCount > 0 {
            isModelDownloading = true
            modelDownloadProgress = Double(progress.completedUnitCount) / Double(progress.totalUnitCount)
        } else {
            isModelDownloading = false
            modelDownloadProgress = 0.0
        }
    }

    func processYouTubeURL(_ urlString: String) async {
        isProcessing = true
        errorMessage = nil
        progress = 0.0
        
        do {
            currentStatus = "Extracting video information..."
            progress = 0.1
        
            let videoInfo: YouTubeExtractor.VideoInfo
            if let cachedVideoInfo = cacheManager.getCachedVideoInfo(for: urlString) {
                currentStatus = "Video information found in cache..."
                videoInfo = cachedVideoInfo
            } else {
                videoInfo = try await youtubeExtractor.extractVideoInfo(from: urlString)
                cacheManager.setCachedVideoInfo(videoInfo, for: urlString)
            }
            
            currentStatus = "Checking cache..."
            progress = 0.2
            
            let transcriptionText: String
            if let cachedTranscription = cacheManager.getCachedTranscription(for: urlString) {
                currentStatus = "Transcription found in cache..."
                progress = 0.6
                transcriptionText = cachedTranscription
            } else {
                currentStatus = "Preparing download..."
                progress = 0.3
                
                let downloadsDirectory = try audioDownloader.getDownloadsDirectory()
                let audioFileName = audioDownloader.generateAudioFileName(for: videoInfo.title)
                let audioFileURL = downloadsDirectory.appendingPathComponent(audioFileName)
                
                currentStatus = "Downloading audio..."
                progress = 0.4
                
                let downloadedAudioURL = try await audioDownloader.downloadAudio(
                    from: videoInfo.audioStreamURL,
                    to: audioFileURL
                )
                
                currentStatus = "Transcription in progress..."
                progress = 0.6
                
                transcriptionText = try await whisperKitService.transcribeAudio(from: downloadedAudioURL)
                cacheManager.setCachedTranscription(transcriptionText, for: urlString)
                try? audioDownloader.deleteAudioFile(at: downloadedAudioURL)
            }
            
            if !summaryService.isModelReady() {
                if isModelDownloading && modelDownloadProgress > 0 {
                    let percentage = Int(modelDownloadProgress * 100)
                    currentStatus = "Downloading Gemma 3n model... (\(percentage)%)"
                } else {
                    currentStatus = "Preparing Gemma 3n model..."
                }
                progress = 0.85
                
                while !summaryService.isModelReady() {
                    try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconde
                    if isModelDownloading && modelDownloadProgress > 0 {
                        let percentage = Int(modelDownloadProgress * 100)
                        currentStatus = "Downloading Gemma 3n model... (\(percentage)%)"
                    }
                }
            }
            
            currentStatus = "Generating summary with Gemma 3n..."
            progress = 0.9
            
            let summary = try await summaryService.generateSummary(from: transcriptionText)
            
            currentStatus = "Saving..."
            progress = 0.95
            
            let transcription = VideoTranscription(
                youtubeURL: urlString,
                videoTitle: videoInfo.title,
                transcriptionText: transcriptionText,
                summary: summary,
                duration: videoInfo.duration ?? 0,
                thumbnailURL: videoInfo.thumbnailURL
            )
            
            modelContext.insert(transcription)
            try modelContext.save()
            
            currentStatus = "Completed!"
            progress = 1.0
            
            try await Task.sleep(nanoseconds: 1_000_000_000)
            
        } catch {
            errorMessage = error.localizedDescription
            currentStatus = "Error: \(error.localizedDescription)"
        }
        
        isProcessing = false
        currentStatus = "En attente..."
        progress = 0.0
    }
    
    func cancelProcessing() {
        audioDownloader.cancelDownload()
        
        isProcessing = false
        currentStatus = "Canceled"
        progress = 0.0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.currentStatus = "Waiting..."
        }
    }
    
    func clearCache() {
        cacheManager.clearAllCache()
    }
    
    func clearCache(for urlString: String) {
        cacheManager.clearCache(for: urlString)
    }
    
    func isMLXModelReady() -> Bool {
        return summaryService.isModelReady()
    }
    
    private func isValidYouTubeURL(_ urlString: String) -> Bool {
        let youtubePatterns = [
            "youtube\\.com/watch\\?v=",
            "youtu\\.be/",
            "youtube\\.com/embed/"
        ]
        
        return youtubePatterns.contains { pattern in
            urlString.range(of: pattern, options: .regularExpression) != nil
        }
    }
    
    deinit {
    }
    
    enum ProcessingError: Error, LocalizedError {
        case invalidURL
        case networkError
        case transcriptionError
        case saveError
        
        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Invalid YouTube URL"
            case .networkError:
                return "Network error"
            case .transcriptionError:
                return "Transcription error"
            case .saveError:
                return "Save error"
            }
        }
    }
}
