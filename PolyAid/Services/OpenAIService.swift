import Foundation

/// An implementation of the `LLMService` protocol that connects to the OpenAI Chat Completions API.
@MainActor
final class OpenAIService: LLMService {

    let providerName: String = "OpenAI"
    private let apiEndpoint = URL(string: "https://api.openai.com/v1/chat/completions")!
    private let urlSession: URLSession

    /// Initializes the service with a specific URLSession.
    /// Allowing session injection is crucial for unit testing.
    /// - Parameter urlSession: The URLSession to use for network requests. Defaults to `.shared`.
    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    func sendMessage(messages: [ChatMessage], apiKey: String) async -> Result<ChatMessage, PolyAidError> {
        // 1. Prepare the request body
        let requestMessages = messages.map { OpenAIChatMessage(role: $0.role.rawValue, content: $0.content) }
        // For now, we hardcode the model. This will be customizable later.
        let requestBody = OpenAIChatRequest(model: "gpt-4o", messages: requestMessages)

        // 2. Create the URLRequest
        var request = URLRequest(url: apiEndpoint)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
        } catch {
            return .failure(.decodingError(description: "Failed to encode request body: \(error.localizedDescription)"))
        }

        // 3. Perform the network call
        do {
            let (data, response) = try await urlSession.data(for: request)

            // Ensure we have a valid HTTP response
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                let nsError = NSError(domain: "HTTPError", code: (response as? HTTPURLResponse)?.statusCode ?? 500, userInfo: [NSLocalizedDescriptionKey: "Invalid server response."])
                return .failure(.networkError(underlyingError: nsError))
            }

            // 4. Decode the response and map to our internal model
            let openAIResponse = try JSONDecoder().decode(OpenAIChatResponse.self, from: data)
            guard let firstChoice = openAIResponse.choices.first else {
                return .failure(.decodingError(description: "Response contained no choices."))
            }

            let assistantMessage = ChatMessage(
                id: UUID(), // Generate a new UUID for our internal model
                role: .assistant,
                content: firstChoice.message.content,
                createdAt: Date()
            )
            return .success(assistantMessage)

        } catch let error as PolyAidError {
            // Re-throw our own errors
            return .failure(error)
        } catch let error as NSError where error.domain == NSURLErrorDomain {
            // Handle URLSession-specific errors (e.g., no internet)
            return .failure(.networkError(underlyingError: error))
        } catch {
            // Handle JSON decoding errors
            return .failure(.decodingError(description: "Failed to decode response JSON: \(error.localizedDescription)"))
        }
    }
}
