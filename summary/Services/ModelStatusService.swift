//
//  ModelStatusService.swift
//  summary
//
//  Created by Assistant on 23/09/2025.
//

import Foundation
import Combine

@MainActor
class ModelStatusService: ObservableObject {
    @Published var gemmaStatus: ModelStatus = .notLoaded
    @Published var whisperKitStatus: ModelStatus = .notLoaded
    @Published var gemmaDownloadProgress: Double = 0.0
    
    var allModelsReady: Bool {
        gemmaStatus == .loaded && whisperKitStatus == .loaded
    }
    
    var statusMessage: String {
        if allModelsReady {
            return "Tous les modèles sont prêts"
        }
        
        var messages: [String] = []
        
        switch gemmaStatus {
        case .notLoaded:
            messages.append("Gemma: Non chargé")
        case .downloading:
            let percentage = Int(gemmaDownloadProgress * 100)
            messages.append("Gemma: Téléchargement \(percentage)%")
        case .loading:
            messages.append("Gemma: Chargement...")
        case .loaded:
            messages.append("Gemma: ✅")
        case .error(let message):
            messages.append("Gemma: ❌ \(message)")
        }
        
        switch whisperKitStatus {
        case .notLoaded:
            messages.append("WhisperKit: Non initialisé")
        case .downloading:
            messages.append("WhisperKit: Téléchargement...")
        case .loading:
            messages.append("WhisperKit: Initialisation...")
        case .loaded:
            messages.append("WhisperKit: ✅")
        case .error(let message):
            messages.append("WhisperKit: ❌ \(message)")
        }
        
        return messages.joined(separator: " | ")
    }
    
    func updateGemmaStatus(_ status: ModelStatus) {
        gemmaStatus = status
    }
    
    func updateWhisperKitStatus(_ status: ModelStatus) {
        whisperKitStatus = status
    }
    
    func updateGemmaDownloadProgress(_ progress: Double) {
        gemmaDownloadProgress = progress
        if gemmaStatus == .downloading && progress >= 1.0 {
            gemmaStatus = .loading
        }
    }
}

enum ModelStatus: Equatable {
    case notLoaded
    case downloading
    case loading
    case loaded
    case error(String)
}