import Foundation
import Combine

@MainActor
final class ChatViewModel: ObservableObject {
	
	// MARK: - Published Properties
	@Published var messages: [ChatMessage] = []
	@Published var userInput: String = ""
	@Published var isLoading: Bool = false
	
	// MARK: - Private Properties
	private let llmService: LLMService
	private let keychainService: KeychainService
	// Use a constant for the service name to avoid magic strings.
	private let openAIServiceIdentifier = "OpenAI"
	
	// MARK: - Initializer
	init(llmService: LLMService, keychainService: KeychainService = KeychainService()) {
		self.llmService = llmService
		self.keychainService = keychainService
	}
	
	// MARK: - Public Methods
	/// Handles the primary user action: sending a message.
	/// This function now retrieves the API key before making the call.
	func sendMessage() {
		let trimmedInput = userInput.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !trimmedInput.isEmpty else { return }
		
		userInput = ""
		
		let userMessage = ChatMessage(id: UUID(), role: .user, content: trimmedInput, createdAt: Date())
		messages.append(userMessage)
		isLoading = true
		
		// --- MODIFICATION START ---
		// Retrieve the API key from the keychain first.
		let keyResult = keychainService.retrieve(for: openAIServiceIdentifier)
		
		guard case .success(let apiKey) = keyResult, let unwrappedApiKey = apiKey, !unwrappedApiKey.isEmpty else {
			// If key retrieval fails or the key is missing, show an error message.
			let errorMessage: String
			if case .failure(let error) = keyResult {
				errorMessage = "Failed to read from Keychain: \(error.localizedDescription)"
			} else {
				errorMessage = "OpenAI API key not found. Please add it in Settings."
			}
			handleServiceResult(.failure(.unknownError(context: errorMessage)))
			return
		}
		// --- MODIFICATION END ---
		
		Task {
			// Pass the retrieved key to the service.
			let result = await llmService.sendMessage(messages: messages, apiKey: unwrappedApiKey)
			handleServiceResult(result)
		}
	}
	
	// MARK: - Private Helper Methods
	private func handleServiceResult(_ result: Result<ChatMessage, PolyAidError>) {
		switch result {
		case .success(let assistantMessage):
			messages.append(assistantMessage)
		case .failure(let error):
			let errorMessage = ChatMessage(
				id: UUID(),
				role: .system,
				content: "Error: \(error.localizedDescription)",
				createdAt: Date()
			)
			messages.append(errorMessage)
		}
		isLoading = false
	}
}
