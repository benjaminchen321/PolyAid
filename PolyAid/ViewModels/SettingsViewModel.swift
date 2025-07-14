import Foundation
import Combine

/// The ViewModel for the Settings view, responsible for managing API keys.
@MainActor
final class SettingsViewModel: ObservableObject {

    // MARK: - Published Properties
    /// The user's input for the OpenAI API key.
    @Published var openAIAPIKeyInput: String = ""
    /// A flag indicating if an OpenAI key is currently saved in the Keychain.
    @Published var isKeySaved: Bool = false
    /// A message to show transient feedback to the user (e.g., "Saved!").
    @Published var feedbackMessage: String = ""

    // MARK: - Private Properties
    private let keychainService: KeychainService
    private let openAIServiceIdentifier = "OpenAI" // Use a constant for the service name.

    // MARK: - Initializer
    init(keychainService: KeychainService = KeychainService()) {
        self.keychainService = keychainService
        // Immediately check if a key is already saved when the view model is created.
        checkIfKeyIsSaved()
    }

    // MARK: - Public Methods
    /// Saves the current API key from the input field to the Keychain.
    func saveAPIKey() {
        // Don't save an empty key.
        guard !openAIAPIKeyInput.isEmpty else { return }

        let result = keychainService.save(apiKey: openAIAPIKeyInput, for: openAIServiceIdentifier)

        switch result {
        case .success:
            isKeySaved = true
            showFeedback(message: "API Key saved successfully!")
        case .failure(let error):
            isKeySaved = false
            showFeedback(message: "Error saving key: \(error.localizedDescription)")
        }
        // Clear the input field for security after attempting to save.
        openAIAPIKeyInput = ""
    }

    /// Deletes the API key from the Keychain.
    func deleteAPIKey() {
        let result = keychainService.delete(for: openAIServiceIdentifier)
        switch result {
        case .success:
            isKeySaved = false
            showFeedback(message: "API Key deleted.")
        case .failure(let error):
            // This is unlikely but handled for completeness.
            showFeedback(message: "Error deleting key: \(error.localizedDescription)")
        }
    }

    // MARK: - Private Helper Methods
    /// Checks the Keychain to see if a key for OpenAI already exists.
    private func checkIfKeyIsSaved() {
        let result = keychainService.retrieve(for: openAIServiceIdentifier)
        switch result {
        case .success(let key):
            // A key exists if it's not nil and not an empty string.
            self.isKeySaved = key != nil && !key!.isEmpty
        case .failure:
            // If retrieval fails, assume no key is saved.
            self.isKeySaved = false
        }
    }

    /// Displays a feedback message to the user for a short duration.
    private func showFeedback(message: String) {
        self.feedbackMessage = message
        // Clear the message after 3 seconds.
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.feedbackMessage = ""
        }
    }
}
