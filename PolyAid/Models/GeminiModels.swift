import Foundation

// This file contains data structures specific to the Google Gemini API.

/// The request body sent to the Gemini API.
struct GeminiRequest: Codable {
	let contents: [GeminiContent]
}

/// Represents a piece of content in the conversation history for the Gemini API.
/// Gemini has a different structure from OpenAI's message list.
struct GeminiContent: Codable {
	let role: String // "user" or "model"
	let parts: [GeminiPart]
}

/// A part of a Gemini content block, which contains the actual text.
struct GeminiPart: Codable {
	let text: String
}

/// The top-level response object from the Gemini API.
struct GeminiResponse: Codable {
	let candidates: [GeminiCandidate]
}

/// A response candidate from the Gemini model.
struct GeminiCandidate: Codable {
	let content: GeminiContent
}
