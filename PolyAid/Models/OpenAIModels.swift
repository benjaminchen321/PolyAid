import Foundation

// This file contains data structures specific to the OpenAI Chat Completions API.
// They are marked `internal` as they are implementation details of the OpenAIService.

/// The request body sent to the OpenAI Chat Completions endpoint.
struct OpenAIChatRequest: Codable {
    let model: String
    let messages: [OpenAIChatMessage]
    // Add other parameters like temperature, max_tokens, etc., here in the future.
}

/// Represents a single message in the format required by the OpenAI API.
struct OpenAIChatMessage: Codable {
    let role: String
    let content: String
}

/// The top-level response object from the OpenAI Chat Completions endpoint.
struct OpenAIChatResponse: Codable {
    let id: String
    let object: String
    let created: Int
    let model: String
    let choices: [Choice]
}

/// Represents one of the possible completions generated by the model.
struct Choice: Codable {
    let index: Int
    let message: OpenAIChatMessage
}
