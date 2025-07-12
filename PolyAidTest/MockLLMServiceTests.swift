import XCTest
@testable import PolyAid

/// Tests for the `MockLLMService` to ensure it behaves as expected.
///
/// This entire test class is marked with `@MainActor` to ensure that all functions
/// within it run on the main actor. This is necessary because `MockLLMService` conforms
/// to the `@MainActor`-isolated `LLMService` protocol, and its properties and methods
/// can only be accessed from the main actor.
@MainActor
final class MockLLMServiceTests: XCTestCase {

    private var mockService: MockLLMService!

    // This method is called before each test.
    override func setUp() {
        super.setUp()
        // Because the class is on the MainActor, this initialization is now safe.
        mockService = MockLLMService()
    }

    // This method is called after each test.
    override func tearDown() {
        mockService = nil
        super.tearDown()
    }

    /// Test that the sendMessage function returns a successful result
    /// and that the response has the correct properties.
    func testSendMessageReturnsSuccessfulMockResponse() async {
        // 1. Arrange
        // Create a sample user message to send.
        let userMessageContent = "Hello, world!"
        let testMessages = [
            ChatMessage(id: UUID(), role: .user, content: userMessageContent, createdAt: Date())
        ]

        // 2. Act
        // Call the sendMessage function and await its result.
        let result = await mockService.sendMessage(messages: testMessages, apiKey: "dummy-key")

        // 3. Assert
        // Use a switch statement for robustly handling the Result type.
        switch result {
        case .success(let responseMessage):
            // Verify the provider name is correct.
            XCTAssertEqual(mockService.providerName, "Mock Service")
            // Verify the response role is 'assistant'.
            XCTAssertEqual(responseMessage.role, .assistant)
            // Verify the response content is not empty and contains the expected text.
            XCTAssertFalse(responseMessage.content.isEmpty)
            XCTAssertTrue(responseMessage.content.contains(userMessageContent))
        case .failure(let error):
            // If the result is a failure, the test should fail.
            XCTFail("The mock service should always return a successful result, but it returned error: \(error.localizedDescription)")
        }
    }
}
