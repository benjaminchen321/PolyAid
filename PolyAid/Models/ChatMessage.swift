import Foundation

/// Represents a single message in a chat conversation.
/// Conforms to Identifiable to be used in SwiftUI lists.
/// Conforms to Codable for potential serialization in the future.
struct ChatMessage: Identifiable, Codable, Equatable {
    /// A unique identifier for the message, useful for UI updates.
    let id: UUID

    /// The role of the entity that produced the message (e.g., user, assistant).
    let role: MessageRole

    /// The text content of the message.
    let content: String

    /// The timestamp when the message was created.
    let createdAt: Date
}

/// Defines the originator of a chat message.
enum MessageRole: String, Codable {
    case user
    case assistant
    case system // For instructions to the model
}
