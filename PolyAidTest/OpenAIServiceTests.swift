import XCTest
@testable import PolyAid

@MainActor
final class OpenAIServiceTests: XCTestCase {

    private var urlSession: URLSession!

    override func setUp() {
        super.setUp()
        // Create a URLSessionConfiguration that uses our mock protocol.
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolMock.self]
        urlSession = URLSession(configuration: config)
    }

    override func tearDown() {
        URLProtocolMock.requestHandler = nil
        urlSession = nil
        super.tearDown()
    }

    func testSendMessage_WhenSuccessful_ReturnsDecodedChatMessage() async {
        // 1. Arrange
        // Define the mock JSON response from the OpenAI API.
        let mockResponseJSON = """
        {
            "id": "chatcmpl-123",
            "object": "chat.completion",
            "created": 1677652288,
            "model": "gpt-4o",
            "choices": [{
                "index": 0,
                "message": {
                    "role": "assistant",
                    "content": "Hello! This is a test response."
                }
            }]
        }
        """
        let mockData = mockResponseJSON.data(using: .utf8)!
        let expectedContent = "Hello! This is a test response."

        // Set up the mock handler to return a successful HTTP response with the mock data.
        URLProtocolMock.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, mockData)
        }

        // Create the service instance, injecting our mocked URLSession.
        let service = OpenAIService(urlSession: urlSession)
        let testMessages = [ChatMessage(id: UUID(), role: .user, content: "Hi", createdAt: Date())]

        // 2. Act
        let result = await service.sendMessage(messages: testMessages, apiKey: "fake-key")

        // 3. Assert
        switch result {
        case .success(let chatMessage):
            XCTAssertEqual(chatMessage.role, .assistant)
            XCTAssertEqual(chatMessage.content, expectedContent)
        case .failure(let error):
            XCTFail("Expected success but got failure: \(error.localizedDescription)")
        }
    }

    func testSendMessage_WhenAPIReturnsError_ReturnsNetworkError() async {
        // 1. Arrange
        // Set up the mock handler to return an error status code (e.g., 401 Unauthorized).
        URLProtocolMock.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 401, httpVersion: nil, headerFields: nil)!
            return (response, nil)
        }

        let service = OpenAIService(urlSession: urlSession)
        let testMessages = [ChatMessage(id: UUID(), role: .user, content: "Hi", createdAt: Date())]

        // 2. Act
        let result = await service.sendMessage(messages: testMessages, apiKey: "invalid-key")

        // 3. Assert
        switch result {
        case .success:
            XCTFail("Expected failure but got success.")
        case .failure(let error):
            // Verify that we correctly mapped the HTTP error to our custom error type.
            guard case .networkError(let underlyingError) = error else {
                XCTFail("Incorrect error type. Expected .networkError, got \(error)")
                return
            }
            XCTAssertEqual(underlyingError.code, 401)
        }
    }
}
