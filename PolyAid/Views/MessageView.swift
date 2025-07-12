import SwiftUI

/// A view that displays a single chat message with appropriate styling
/// based on the message's role (user, assistant, or system).
struct MessageView: View {
    /// The message to be displayed by this view.
    let message: ChatMessage

    var body: some View {
        // Use an Hstack to align messages to the leading or trailing edge.
        HStack {
            // User messages are aligned to the right.
            if message.role == .user {
                Spacer()
            }

            // The main content of the message bubble.
            VStack(alignment: .leading, spacing: 4) {
                Text(message.role.rawValue.capitalized)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)

                Text(message.content)
                    .textSelection(.enabled) // Allow users to select and copy text.
            }
            .padding(12)
            .background(backgroundColor(for: message.role))
            .cornerRadius(16)
            .frame(maxWidth: .infinity, alignment: message.role == .user ? .trailing : .leading)


            // Assistant and system messages are aligned to the left.
            if message.role != .user {
                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }

    /// Determines the background color of the message bubble based on its role.
    /// - Parameter role: The role of the message's author.
    /// - Returns: The appropriate color for the background.
    private func backgroundColor(for role: MessageRole) -> Color {
        switch role {
        case .user:
            return .blue.opacity(0.8)
        case .assistant:
            return .gray.opacity(0.3)
        case .system:
            return .red.opacity(0.4)
        }
    }
}
