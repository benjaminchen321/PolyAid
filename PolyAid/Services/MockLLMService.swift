import Foundation

/// A mock implementation of the `LLMService` protocol for testing and UI development.
/// This service does not perform any network requests. Instead, it returns a
/// predefined, canned response after a short, artificial delay to simulate network latency.
final class MockLLMService: LLMService {

    /// The name of the mock service provider.
    let providerName: String = "Mock Service"

    /// Simulates sending a message and receiving a response from an LLM.
    ///
    /// This function introduces a 1-second delay to mimic a real network call.
    /// It always returns a successful result with a fixed assistant message.
    ///
    /// - Parameters:
    ///   - messages: A list of messages, ignored by the mock but required by the protocol.
    ///   - apiKey: The API key, ignored by the mock.
    /// - Returns: A `Result` containing a successful `ChatMessage` from the assistant.
    func sendMessage(messages: [ChatMessage], apiKey: String) async -> Result<ChatMessage, PolyAidError> {
        // Simulate network latency with a 1-second delay.
        try? await Task.sleep(nanoseconds: 1_000_000_000)

        // Create a canned response message.
        let responseMessage = ChatMessage(
            id: UUID(),
            role: .assistant,
            content: "This is a mock response from the \(providerName). The last user message was: '\(messages.last?.content ?? "none")'",
            createdAt: Date()
        )

        // Return the successful result.
        return .success(responseMessage)
    }
}
