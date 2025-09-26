//
//  TranscriptionService.swift
//  summary
//
//  Created by Assistant on 25/09/2025.
//

import Foundation
import Combine

class TranscriptionService: ObservableObject {
    
    enum TranscriptionError: Error, LocalizedError {
        case modelNotFound
        case audioFileNotFound
        case transcriptionFailed(Error)
        case unsupportedAudioFormat
        case modelLoadingFailed
        case insufficientMemory
        
        var errorDescription: String? {
            switch self {
            case .modelNotFound:
                return "Modèle de transcription non trouvé"
            case .audioFileNotFound:
                return "Fichier audio non trouvé"
            case .transcriptionFailed(let error):
                return "Échec de la transcription: \(error.localizedDescription)"
            case .unsupportedAudioFormat:
                return "Format audio non supporté"
            case .modelLoadingFailed:
                return "Impossible de charger le modèle"
            case .insufficientMemory:
                return "Mémoire insuffisante pour la transcription"
            }
        }
    }
    
    struct TranscriptionProgress {
        let currentSegment: Int
        let totalSegments: Int
        let percentage: Double
        let currentText: String?
        
        init(currentSegment: Int, totalSegments: Int, currentText: String? = nil) {
            self.currentSegment = currentSegment
            self.totalSegments = totalSegments
            self.percentage = totalSegments > 0 ? Double(currentSegment) / Double(totalSegments) : 0.0
            self.currentText = currentText
        }
    }
    
    struct TranscriptionResult {
        let fullText: String
        let segments: [TranscriptionSegment]
        let duration: TimeInterval
        let language: String?
    }
    
    struct TranscriptionSegment {
        let text: String
        let startTime: TimeInterval
        let endTime: TimeInterval
        let confidence: Double?
    }
    
    @Published var transcriptionProgress: TranscriptionProgress?
    @Published var isTranscribing = false
    @Published var isModelLoaded = false
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Configuration MLX
    private let modelName = "mlx-community/whisper-tiny-mlx"
    private var modelPath: URL?
    
    init() {
        setupModelPath()
    }
    
    /// Configure le chemin du modèle MLX
    private func setupModelPath() {
        do {
            let documentsDirectory = try FileManager.default.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            
            let modelsDirectory = documentsDirectory.appendingPathComponent("Models")
            
            // Créer le répertoire des modèles s'il n'existe pas
            if !FileManager.default.fileExists(atPath: modelsDirectory.path) {
                try FileManager.default.createDirectory(at: modelsDirectory, withIntermediateDirectories: true)
            }
            
            modelPath = modelsDirectory.appendingPathComponent("whisper-tiny")
            
        } catch {
            print("Erreur lors de la configuration du chemin du modèle: \(error)")
        }
    }
    
    /// Vérifie si le modèle est disponible localement
    func isModelAvailable() -> Bool {
        guard let modelPath = modelPath else { return false }
        return FileManager.default.fileExists(atPath: modelPath.path)
    }
    
    /// Télécharge le modèle MLX si nécessaire
    func downloadModelIfNeeded() async throws {
        guard !isModelAvailable() else {
            DispatchQueue.main.async {
                self.isModelLoaded = true
            }
            return
        }
        
        // Pour l'instant, on simule le téléchargement du modèle
        // Dans une vraie implémentation, il faudrait télécharger depuis Hugging Face
        try await simulateModelDownload()
        
        DispatchQueue.main.async {
            self.isModelLoaded = true
        }
    }
    
    /// Simule le téléchargement du modèle (pour la démo)
    private func simulateModelDownload() async throws {
        guard let modelPath = modelPath else {
            throw TranscriptionError.modelLoadingFailed
        }
        
        // Créer un fichier de modèle factice pour la démo
        let modelData = "MLX Whisper Model Placeholder".data(using: .utf8)!
        try modelData.write(to: modelPath)
    }
    
    /// Transcrit un fichier audio
    func transcribeAudio(at audioURL: URL) async throws -> TranscriptionResult {
        // Vérifier que le fichier audio existe
        guard FileManager.default.fileExists(atPath: audioURL.path) else {
            throw TranscriptionError.audioFileNotFound
        }
        
        // Vérifier que le modèle est disponible
        try await downloadModelIfNeeded()
        
        DispatchQueue.main.async {
            self.isTranscribing = true
            self.transcriptionProgress = TranscriptionProgress(currentSegment: 0, totalSegments: 100)
        }
        
        do {
            // Simuler la transcription avec MLX
            let result = try await performMLXTranscription(audioURL: audioURL)
            
            DispatchQueue.main.async {
                self.isTranscribing = false
                self.transcriptionProgress = nil
            }
            
            return result
            
        } catch {
            DispatchQueue.main.async {
                self.isTranscribing = false
                self.transcriptionProgress = nil
            }
            throw TranscriptionError.transcriptionFailed(error)
        }
    }
    
    /// Effectue la transcription avec MLX (version simulée)
    private func performMLXTranscription(audioURL: URL) async throws -> TranscriptionResult {
        // IMPORTANT: Cette implémentation est simulée pour la démo
        // Dans une vraie app, il faudrait utiliser MLX-Swift avec Whisper
        
        // Simuler le processus de transcription avec des mises à jour de progression
        let totalSegments = 10
        var segments: [TranscriptionSegment] = []
        
        for i in 0..<totalSegments {
            // Simuler le traitement d'un segment
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconde
            
            let startTime = Double(i) * 6.0 // 6 secondes par segment
            let endTime = startTime + 6.0
            let segmentText = "Ceci est le segment \(i + 1) de la transcription simulée."
            
            let segment = TranscriptionSegment(
                text: segmentText,
                startTime: startTime,
                endTime: endTime,
                confidence: 0.95
            )
            segments.append(segment)
            
            // Mettre à jour la progression
            DispatchQueue.main.async {
                self.transcriptionProgress = TranscriptionProgress(
                    currentSegment: i + 1,
                    totalSegments: totalSegments,
                    currentText: segmentText
                )
            }
        }
        
        let fullText = segments.map { $0.text }.joined(separator: " ")
        
        return TranscriptionResult(
            fullText: fullText,
            segments: segments,
            duration: Double(totalSegments) * 6.0,
            language: "fr"
        )
    }
    
    /// Annule la transcription en cours
    func cancelTranscription() {
        // Dans une vraie implémentation, il faudrait annuler le processus MLX
        DispatchQueue.main.async {
            self.isTranscribing = false
            self.transcriptionProgress = nil
        }
    }
    
    /// Génère un résumé de la transcription
    func generateSummary(from transcription: String) async -> String {
        // Pour l'instant, on génère un résumé simple
        // Dans une vraie app, on pourrait utiliser un modèle de langage local
        
        let words = transcription.components(separatedBy: .whitespacesAndNewlines)
        let wordCount = words.count
        
        if wordCount < 50 {
            return "Transcription courte: \(transcription.prefix(100))..."
        } else {
            let sentences = transcription.components(separatedBy: ". ")
            let firstSentences = Array(sentences.prefix(3)).joined(separator: ". ")
            return "Résumé: \(firstSentences)..."
        }
    }
    
    /// Nettoie les ressources
    deinit {
        cancellables.removeAll()
    }
}