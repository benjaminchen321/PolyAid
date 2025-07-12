import Foundation

/// Defines a standard contract for interacting with any Large Language Model,
/// whether it's a remote API or a local model.
@MainActor // Ensures completion handlers are called on the main thread for UI updates.
protocol LLMService {
    /// The name of the service provider (e.g., "OpenAI", "Gemini").
    var providerName: String { get }

    /// Sends a collection of messages to the LLM and receives a response.
    ///
    /// - Parameters:
    ///   - messages: An array of `ChatMessage` objects representing the conversation history.
    ///   - apiKey: The API key for authenticating with the service.
    /// - Returns: A `Result` containing either the successful `ChatMessage` response
    ///            from the assistant or a `PolyAidError`.
    func sendMessage(messages: [ChatMessage], apiKey: String) async -> Result<ChatMessage, PolyAidError>
}
