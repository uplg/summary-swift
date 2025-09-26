import Foundation
import MLXLLM
import MLXLMCommon

extension LLMRegistry {
    static let gemma3nE2B4bit = ModelConfiguration(
        id: "mlx-community/gemma-3n-E2B-it-lm-4bit",
        overrideTokenizer: "PreTrainedTokenizer",
        defaultPrompt: "Summarize the following text in the original language concisely and clearly:"
    )
}
