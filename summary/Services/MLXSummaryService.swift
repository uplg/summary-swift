import Foundation
import Combine
import MLXLLM
import MLXLMCommon
import Hub
internal import Tokenizers

@MainActor
class MLXSummaryService: ObservableObject {
    @Published var isGenerating = false
    @Published var progress: Double = 0.0
    @Published var lastError: SummaryError?
    @Published var downloadProgress: Progress = Progress(totalUnitCount: 0)
    @Published var isModelLoaded = false
    
    private var modelContainer: ModelContainer?
    private let modelConfiguration = LLMRegistry.gemma3nE2B4bit
    private let hub = HubApi(downloadBase: URL.downloadsDirectory.appending(path: "huggingface"))
    
    init() {
        Task {
            await loadModel()
        }
    }
    
    func generateSummary(from text: String) async throws -> String {
        isGenerating = true
        
        // Charger le modèle s'il n'est pas encore chargé
        if modelContainer == nil {
            await loadModel()
        }
        
        guard let modelContainer else { 
            isGenerating = false
            throw SummaryError.generationFailed("Modèle Gemma non chargé")
        }
        
        defer {
            isGenerating = false
            progress = 0.0
        }
        
        do {
            var output = ""
            
            let result = try await modelContainer.perform { context in
                let prompt = await createGemmaPrompt(from: text)
                
                // Créer l'entrée utilisateur
                var userInput = UserInput(prompt: prompt)
                
                // Créer l'entrée LM
                let input = try await context.processor.prepare(input: userInput)
                
                // Générer la sortie
                return try MLXLMCommon.generate(input: input, parameters: .init(), context: context) { tokens in
                    let text = context.tokenizer.decode(tokens: tokens)
                    
                    Task { @MainActor in
                        output = text
                        self.progress = min(Double(tokens.count) / 200.0, 0.9)
                    }
                    
                    // Arrêter si on détecte la fin du résumé ou si c'est trop long
                    if text.contains("</résumé>") || text.contains("[FIN]") || tokens.count > 200 {
                        return .stop
                    }
                    
                    return .more
                }
            }
            
            progress = 1.0
            
            // Extraire le résumé de la réponse de Gemma
            let summary = extractSummaryFromGemmaResponse(output)
            
            if summary.isEmpty {
                throw SummaryError.generationFailed("Gemma n'a pas pu générer un résumé valide")
            }
            
            return summary
            
        } catch {
            lastError = SummaryError.generationFailed("Erreur Gemma: \(error.localizedDescription)")
            throw SummaryError.generationFailed("Erreur lors de la génération avec Gemma: \(error.localizedDescription)")
        }
    }
    
    func isModelReady() -> Bool {
        return isModelLoaded && modelContainer != nil
    }
    
    private var modelFactory: ModelFactory {
        // If the model is in LLM model registry then it is a LLM
        let isLLM = LLMModelFactory.shared.modelRegistry.models.contains { $0.name == modelConfiguration.name }

        // If the model is a LLM, select LLMFactory. If not, select VLM factory
        return LLMModelFactory.shared
    }
    
    private func loadModel() async {
        do {
            downloadProgress = Progress(totalUnitCount: 0)
            isModelLoaded = false
            
            // Load the model with the appropriate factory
            modelContainer = try await modelFactory.loadContainer(
                // hub: hub, // Comment out here if you want to use default download directory.
                configuration: modelConfiguration
            ) { progress in
                Task { @MainActor in
                    print(progress.fractionCompleted)
                    self.downloadProgress = progress
                }
            }
            
            self.isModelLoaded = true
            self.downloadProgress = Progress(totalUnitCount: 1)
        } catch {
            lastError = SummaryError.generationFailed("Erreur Gemma: \(error.localizedDescription)")
        }

    }
    
    private func createGemmaPrompt(from text: String) -> String {
        // Prompt optimisé pour Gemma 3n en français
        return """
        <bos>Tu es un assistant IA spécialisé dans la création de résumés. Ton rôle est de créer un résumé concis et informatif du texte suivant.

        Instructions:
        - Crée un résumé en français de 3-4 phrases maximum
        - Capture les points clés et les informations essentielles
        - Utilise un langage clair et accessible
        - Termine par </résumé>

        Texte à résumer:
        \(text.prefix(3000))

        Résumé:
        """
    }
    
    private func extractSummaryFromGemmaResponse(_ response: String) -> String {
        // Nettoyer la réponse de Gemma
        var cleanedResponse = response
        
        // Supprimer les balises de fin
        cleanedResponse = cleanedResponse.replacingOccurrences(of: "</résumé>", with: "")
        cleanedResponse = cleanedResponse.replacingOccurrences(of: "[FIN]", with: "")
        cleanedResponse = cleanedResponse.replacingOccurrences(of: "<eos>", with: "")
        
        // Supprimer les espaces en trop
        cleanedResponse = cleanedResponse.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Si la réponse est vide ou trop courte, retourner un résumé par défaut
        if cleanedResponse.isEmpty || cleanedResponse.count < 20 {
            return "Résumé généré par Gemma non disponible."
        }
        
        // Limiter la longueur du résumé
        if cleanedResponse.count > 500 {
            let truncated = String(cleanedResponse.prefix(500))
            if let lastSentence = truncated.lastIndex(of: ".") {
                cleanedResponse = String(truncated[...lastSentence])
            } else {
                cleanedResponse = truncated + "..."
            }
        }
        
        return cleanedResponse
    }
    
    deinit {
        modelContainer = nil
    }
}
