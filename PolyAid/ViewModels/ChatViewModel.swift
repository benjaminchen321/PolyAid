//
//  ChatViewModel.swift
//  PolyAid
//
//  Created by Benjamin Chen on 7/8/25.
//


import Foundation
import Combine // Needed for ObservableObject

/// The ViewModel responsible for managing the state and logic of the chat view.
/// It is the single source of truth for the chat interface.
@MainActor // Ensures all updates to @Published properties happen on the main thread.
final class ChatViewModel: ObservableObject {

    // MARK: - Published Properties
    // These properties will trigger UI updates when they change.

    /// The list of messages currently in the chat history.
    @Published var messages: [ChatMessage] = []
    /// The content of the text input field where the user types their message.
    @Published var userInput: String = ""
    /// A flag indicating if the ViewModel is currently waiting for a response from the LLM.
    @Published var isLoading: Bool = false

    // MARK: - Private Properties

    /// The service used to communicate with the LLM. This is injected during initialization
    /// to allow for easy swapping between mock and real services.
    private let llmService: LLMService
    /// The service for securely handling API keys.
    private let keychainService: KeychainService

    // MARK: - Initializer

    /// Initializes the ViewModel with the necessary services.
    ///
    /// - Parameters:
    ///   - llmService: An object conforming to the `LLMService` protocol.
    ///   - keychainService: The service for managing keychain access.
    init(llmService: LLMService, keychainService: KeychainService = KeychainService()) {
        self.llmService = llmService
        self.keychainService = keychainService
    }

    // MARK: - Public Methods

    /// Handles the primary user action: sending a message.
    func sendMessage() {
        // Prevent sending empty messages.
        let trimmedInput = userInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedInput.isEmpty else { return }

        // Clear the input field immediately for a responsive feel.
        userInput = ""

        // Create and append the user's message to the chat history.
        let userMessage = ChatMessage(id: UUID(), role: .user, content: trimmedInput, createdAt: Date())
        messages.append(userMessage)

        // Set the loading state to true to indicate an operation is in progress.
        isLoading = true

        // Launch an asynchronous task to fetch the LLM's response.
        Task {
            // For the MVP, we'll use a dummy API key. In a real scenario,
            // this would be retrieved from the keychainService.
            let apiKey = "dummy-key-for-now"

            let result = await llmService.sendMessage(messages: messages, apiKey: apiKey)

            // Once the async operation is complete, update state.
            handleServiceResult(result)
        }
    }

    // MARK: - Private Helper Methods

    /// Processes the result from the LLMService and updates the state accordingly.
    private func handleServiceResult(_ result: Result<ChatMessage, PolyAidError>) {
        switch result {
        case .success(let assistantMessage):
            // If the call was successful, append the assistant's message.
            messages.append(assistantMessage)

        case .failure(let error):
            // If the call failed, create and append an error message to the chat.
            // This is crucial for our developer-focused audience.
            let errorMessage = ChatMessage(
                id: UUID(),
                role: .system, // Use 'system' role for error messages.
                content: "Error: \(error.localizedDescription)",
                createdAt: Date()
            )
            messages.append(errorMessage)
        }
        // The operation is complete, so set loading to false.
        isLoading = false
    }
}