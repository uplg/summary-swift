//
//  SummaryService.swift
//  summary
//
//  Created by Assistant on 25/09/2025.
//

import Foundation
import Combine

@MainActor
class SummaryService: ObservableObject {
    @Published var isGenerating = false
    @Published var progress: Double = 0.0
    @Published var lastError: SummaryError?
    
    init() {
        // Service de résumé simple sans modèle ML
    }
    
    func generateSummary(from text: String) async throws -> String {
        await MainActor.run {
            self.isGenerating = true
            self.progress = 0.0
            self.lastError = nil
        }
        
        defer {
            Task { @MainActor in
                self.isGenerating = false
                self.progress = 0.0
            }
        }
        
        do {
            // Simulation du traitement avec progression
            for i in 0...10 {
                await MainActor.run {
                    self.progress = Double(i) / 10.0
                }
                try await Task.sleep(nanoseconds: 100_000_000) // 100ms
            }
            
            // Algorithme de résumé simple basé sur les phrases
            let summary = createBasicSummary(from: text)
            
            await MainActor.run {
                self.progress = 1.0
            }
            
            return summary
            
        } catch {
            await MainActor.run {
                self.lastError = SummaryError.generationFailed(error.localizedDescription)
            }
            throw SummaryError.generationFailed(error.localizedDescription)
        }
    }
    
    private func createBasicSummary(from text: String) -> String {
        // Algorithme de résumé simple
        let sentences = text.components(separatedBy: CharacterSet(charactersIn: ".!?"))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        if sentences.isEmpty {
            return "Aucun contenu à résumer."
        }
        
        // Prendre les 2-3 premières phrases significatives
        let maxSentences = min(3, sentences.count)
        let selectedSentences = Array(sentences.prefix(maxSentences))
        
        return selectedSentences.joined(separator: ". ") + "."
    }
    
    func isModelReady() -> Bool {
        return !isGenerating
    }
}

enum SummaryError: Error, LocalizedError {
    case generationFailed(String)
    case invalidInput
    
    var errorDescription: String? {
        switch self {
        case .generationFailed(let message):
            return "Échec de la génération du résumé: \(message)"
        case .invalidInput:
            return "Texte d'entrée invalide"
        }
    }
}