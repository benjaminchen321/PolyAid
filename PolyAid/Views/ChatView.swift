import SwiftUI

/// The main chat interface view, containing the message list and input controls.
/// This view is driven by the `ChatViewModel`.
struct ChatView: View {
    /// The ViewModel that provides state and logic for this view.
    /// `@ObservedObject` ensures the view re-renders when the ViewModel's
    /// `@Published` properties change.
    @ObservedObject var viewModel: ChatViewModel

    var body: some View {
        VStack(spacing: 0) {
            // The area where messages are displayed.
            ScrollView {
                // LazyVStack is efficient for long lists of messages.
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.messages) { message in
                        MessageView(message: message)
                    }
                }
            }

            // A divider to separate the message list from the input area.
            Divider()

            // The input area at the bottom.
            HStack(spacing: 12) {
                // The text field for user input.
                TextField("Enter your message...", text: $viewModel.userInput)
                    .textFieldStyle(.plain)
                    .onSubmit(viewModel.sendMessage) // Send on pressing Enter.

                // A button to send the message.
                Button(action: viewModel.sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title)
                }
                .buttonStyle(.borderless)
                .tint(.blue)
                // Disable the button if a message is empty or loading.
                .disabled(viewModel.userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isLoading)

                // Show a progress indicator while waiting for a response.
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                        .frame(width: 28, height: 28)
                }
            }
            .padding()
        }
    }
}
