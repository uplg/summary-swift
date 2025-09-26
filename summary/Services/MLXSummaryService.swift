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
    private let statusService: ModelStatusService
    
    init(statusService: ModelStatusService) {
        self.statusService = statusService
        Task {
            await loadModel()
        }
    }
    
    func generateSummary(from text: String) async throws -> String {
        isGenerating = true
        
        if modelContainer == nil {
            await loadModel()
        }
        
        guard let modelContainer else { 
            isGenerating = false
            throw SummaryError.generationFailed("Gemma model not loaded")
        }
        
        defer {
            isGenerating = false
            progress = 0.0
        }
        
        do {
            var output = ""
            
            let result = try await modelContainer.perform { context in
                let prompt = await createGemmaPrompt(from: text)
                
                var userInput = UserInput(prompt: prompt)
                
                let input = try await context.processor.prepare(input: userInput)
                
                return try MLXLMCommon.generate(input: input, parameters: .init(), context: context) { tokens in
                    let text = context.tokenizer.decode(tokens: tokens)
                    
                    Task { @MainActor in
                        output = text
                        self.progress = min(Double(tokens.count) / 200.0, 0.9)
                    }
                    
                    if text.contains("</summary>") || text.contains("[END]") || tokens.count > 200 {
                        return .stop
                    }
                    
                    return .more
                }
            }
            
            progress = 1.0
            
            let summary = extractSummaryFromGemmaResponse(output)
            
            if summary.isEmpty {
                throw SummaryError.generationFailed("Gemma could not generate a valid summary")
            }
            
            return summary
            
        } catch {
            lastError = SummaryError.generationFailed("Gemma error: \(error.localizedDescription)")
            throw SummaryError.generationFailed("Error during generation with Gemma: \(error.localizedDescription)")
        }
    }
    
    func isModelReady() -> Bool {
        return isModelLoaded && modelContainer != nil
    }
    
    private var modelFactory: ModelFactory {
        let isLLM = LLMModelFactory.shared.modelRegistry.models.contains { $0.name == modelConfiguration.name }
        return LLMModelFactory.shared
    }
    
    private func loadModel() async {
        do {
            downloadProgress = Progress(totalUnitCount: 0)
            isModelLoaded = false
            statusService.updateGemmaStatus(.downloading)
            
            modelContainer = try await modelFactory.loadContainer(
                // hub: hub,
                configuration: modelConfiguration
            ) { progress in
                Task { @MainActor in
                    print(progress.fractionCompleted)
                    self.downloadProgress = progress
                    self.statusService.updateGemmaDownloadProgress(progress.fractionCompleted)
                    
                    if progress.fractionCompleted >= 1.0 {
                        self.statusService.updateGemmaStatus(.loading)
                    }
                }
            }
            
            self.isModelLoaded = true
            self.downloadProgress = Progress(totalUnitCount: 1)
            statusService.updateGemmaStatus(.loaded)
        } catch {
            let errorMessage = "Gemma error: \(error.localizedDescription)"
            lastError = SummaryError.generationFailed(errorMessage)
            statusService.updateGemmaStatus(.error(errorMessage))
        }

    }
    
    private func createGemmaPrompt(from text: String) -> String {
        return """
        <bos>You are a specialized AI assistant designed to create concise and informative summaries. Your task is to create a summary of the following text in the original language.

        Instructions:
        - Create a summary in the ORIGINAL language of 3-4 sentences maximum
        - Capture the key points and essential information
        - Use clear and accessible language
        - End with </summary>

        Text to summarize:
        \(text)

        Summary:
        """
    }
    
    private func extractSummaryFromGemmaResponse(_ response: String) -> String {
        var cleanedResponse = response
        
        cleanedResponse = cleanedResponse.replacingOccurrences(of: "</summary>", with: "")
        cleanedResponse = cleanedResponse.replacingOccurrences(of: "[END]", with: "")
        cleanedResponse = cleanedResponse.replacingOccurrences(of: "<eos>", with: "")
        
        cleanedResponse = cleanedResponse.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if cleanedResponse.isEmpty {
            return "Summary generated by Gemma not available."
        }
        
        return cleanedResponse
    }
    
    deinit {
        modelContainer = nil
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