import XCTest
@testable import PolyAid

@MainActor
final class GeminiServiceTests: XCTestCase {

    private var urlSession: URLSession!

    override func setUp() {
        super.setUp()
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
        let mockResponseJSON = """
        {
            "candidates": [{
                "content": {
                    "parts": [{"text": "This is a test response from Gemini."}],
                    "role": "model"
                }
            }]
        }
        """
        let mockData = mockResponseJSON.data(using: .utf8)!
        let expectedContent = "This is a test response from Gemini."

        URLProtocolMock.requestHandler = { request in
            // Verify the correct API key header is being used.
            XCTAssertEqual(request.value(forHTTPHeaderField: "x-goog-api-key"), "fake-gemini-key")
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, mockData)
        }

        let service = GeminiService(urlSession: urlSession)
        let testMessages = [ChatMessage(id: UUID(), role: .user, content: "Hi", createdAt: Date())]

        // 2. Act
        let result = await service.sendMessage(messages: testMessages, apiKey: "fake-gemini-key")

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
        URLProtocolMock.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 400, httpVersion: nil, headerFields: nil)!
            return (response, nil)
        }

        let service = GeminiService(urlSession: urlSession)
        let testMessages = [ChatMessage(id: UUID(), role: .user, content: "Hi", createdAt: Date())]

        // 2. Act
        let result = await service.sendMessage(messages: testMessages, apiKey: "invalid-key")

        // 3. Assert
        guard case .failure(let error) = result else {
            XCTFail("Expected failure but got success.")
            return
        }
        guard case .networkError = error else {
            XCTFail("Incorrect error type. Expected .networkError, got \(error)")
            return
        }
    }
}