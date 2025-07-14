import SwiftUI

/// A view for managing application settings, such as API keys.
struct SettingsView: View {
    /// The view model that drives this view.
    @StateObject private var viewModel = SettingsViewModel()
    /// The presentation mode environment value to dismiss the sheet.
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(spacing: 20) {
            Text("API Key Management")
                .font(.title2)
                .fontWeight(.bold)

            // Form for OpenAI API Key
            Form {
                Section(header: Text("OpenAI")) {
                    // Use SecureField for sensitive input.
                    SecureField("Enter your OpenAI API Key", text: $viewModel.openAIAPIKeyInput)

                    HStack {
                        Button("Save Key", action: viewModel.saveAPIKey)
                            .disabled(viewModel.openAIAPIKeyInput.isEmpty)

                        Spacer()

                        if viewModel.isKeySaved {
                            Button("Delete Key", role: .destructive, action: viewModel.deleteAPIKey)
                        }
                    }

                    // Display status and feedback.
                    Text(viewModel.isKeySaved ? "An OpenAI key is saved in your Keychain." : "No OpenAI key is saved.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // Display the transient feedback message.
            if !viewModel.feedbackMessage.isEmpty {
                Text(viewModel.feedbackMessage)
                    .font(.footnote)
                    .foregroundColor(.accentColor)
                    .transition(.opacity)
            }

            // Done button to close the sheet.
            Button("Done") {
                presentationMode.wrappedValue.dismiss()
            }
            .keyboardShortcut(.defaultAction) // Binds to the Enter key.

        }
        .padding()
        .frame(width: 450, height: 300)
    }
}
