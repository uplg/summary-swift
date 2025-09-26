//
//  YouTubeProcessor.swift
//  summary
//
//  Created by Assistant on 25/09/2025.
//

import Foundation
import SwiftData
import Combine

@MainActor
class YouTubeProcessor: ObservableObject {
    @Published var isProcessing = false
    @Published var currentStatus = "En attente..."
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
    
    // Cache persistant pour les résultats par URL
    private let cacheManager = CacheManager.shared
    
    // Exposer le service de statut pour l'interface utilisateur
    var modelStatusService: ModelStatusService {
        return statusService
    }
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        
        // Initialiser les services avec le service de statut partagé
        self.whisperKitService = WhisperKitTranscriptionService(statusService: statusService)
        self.summaryService = MLXSummaryService(statusService: statusService)
        
        // Nettoyer automatiquement le cache ancien au démarrage
        cacheManager.cleanOldCache()
        
        // Observer le progrès de téléchargement du modèle
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

    
    /// Traite une URL YouTube complète
    func processYouTubeURL(_ urlString: String) async {
        isProcessing = true
        errorMessage = nil
        progress = 0.0
        
        do {
            // Étape 1: Validation et extraction des informations
            currentStatus = "Extraction des informations vidéo..."
            progress = 0.1
            
            // Vérifier le cache pour les informations vidéo
            let videoInfo: YouTubeExtractor.VideoInfo
            if let cachedVideoInfo = cacheManager.getCachedVideoInfo(for: urlString) {
                currentStatus = "Informations vidéo trouvées en cache..."
                videoInfo = cachedVideoInfo
            } else {
                videoInfo = try await youtubeExtractor.extractVideoInfo(from: urlString)
                // Mettre en cache le résultat
                cacheManager.setCachedVideoInfo(videoInfo, for: urlString)
            }
            
            // Étape 2: Vérification du cache de transcription
            currentStatus = "Vérification du cache..."
            progress = 0.2
            
            let transcriptionText: String
            if let cachedTranscription = cacheManager.getCachedTranscription(for: urlString) {
                currentStatus = "Transcription trouvée en cache..."
                progress = 0.6
                transcriptionText = cachedTranscription
            } else {
                // Étape 3: Préparation du téléchargement
                currentStatus = "Préparation du téléchargement..."
                progress = 0.3
                
                let downloadsDirectory = try audioDownloader.getDownloadsDirectory()
                let audioFileName = audioDownloader.generateAudioFileName(for: videoInfo.title)
                let audioFileURL = downloadsDirectory.appendingPathComponent(audioFileName)
                
                // Étape 4: Téléchargement de l'audio
                currentStatus = "Téléchargement de l'audio..."
                progress = 0.4
                
                let downloadedAudioURL = try await audioDownloader.downloadAudio(
                    from: videoInfo.audioStreamURL,
                    to: audioFileURL
                )
                
                // Étape 5: Transcription avec WhisperKit
                currentStatus = "Transcription en cours..."
                progress = 0.6
                
                transcriptionText = try await whisperKitService.transcribeAudio(from: downloadedAudioURL)
                // Mettre en cache le résultat
                cacheManager.setCachedTranscription(transcriptionText, for: urlString)
                // Nettoyer le fichier audio temporaire après transcription
                try? audioDownloader.deleteAudioFile(at: downloadedAudioURL)
            }
            
            // Étape 5: Génération du résumé avec MLX
            if !summaryService.isModelReady() {
                if isModelDownloading && modelDownloadProgress > 0 {
                    let percentage = Int(modelDownloadProgress * 100)
                    currentStatus = "Téléchargement du modèle Gemma 3n... (\(percentage)%)"
                } else {
                    currentStatus = "Préparation du modèle Gemma 3n..."
                }
                progress = 0.85
                
                // Attendre que le modèle soit prêt
                while !summaryService.isModelReady() {
                    try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconde
                    if isModelDownloading && modelDownloadProgress > 0 {
                        let percentage = Int(modelDownloadProgress * 100)
                        currentStatus = "Téléchargement du modèle Gemma 3n... (\(percentage)%)"
                    }
                }
            }
            
            currentStatus = "Génération du résumé avec Gemma 3n..."
            progress = 0.9
            
            let summary = try await summaryService.generateSummary(from: transcriptionText)
            
            // Étape 6: Sauvegarde
            currentStatus = "Sauvegarde..."
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
            
            // Terminé
            currentStatus = "Terminé !"
            progress = 1.0
            
            // Attendre un peu avant de réinitialiser
            try await Task.sleep(nanoseconds: 1_000_000_000)
            
        } catch {
            errorMessage = error.localizedDescription
            currentStatus = "Erreur: \(error.localizedDescription)"
        }
        
        // Réinitialisation
        isProcessing = false
        currentStatus = "En attente..."
        progress = 0.0
    }
    

    

    
    /// Annule le traitement en cours
    func cancelProcessing() {
        audioDownloader.cancelDownload()
        // Note: WhisperKit ne supporte pas l'annulation directe
        
        isProcessing = false
        currentStatus = "Annulé"
        progress = 0.0
        
        // Réinitialiser après un délai
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.currentStatus = "En attente..."
        }
    }
    
    /// Vide le cache des résultats
    func clearCache() {
        cacheManager.clearAllCache()
    }
    
    // Vider le cache pour une URL spécifique
    func clearCache(for urlString: String) {
        cacheManager.clearCache(for: urlString)
    }
    
    func isMLXModelReady() -> Bool {
        return summaryService.isModelReady()
    }
    
    /// Vérifie si une URL YouTube est valide
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
    
    /// Nettoie les ressources
    deinit {
        // Nettoyage des ressources si nécessaire
    }
    
    enum ProcessingError: Error, LocalizedError {
        case invalidURL
        case networkError
        case transcriptionError
        case saveError
        
        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "URL YouTube invalide"
            case .networkError:
                return "Erreur de réseau"
            case .transcriptionError:
                return "Erreur de transcription"
            case .saveError:
                return "Erreur de sauvegarde"
            }
        }
    }
}
