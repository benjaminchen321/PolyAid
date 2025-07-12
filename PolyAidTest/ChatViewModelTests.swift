import XCTest
@testable import PolyAid

/// Tests for the `ChatViewModel` to ensure its state management and logic are correct.
@MainActor
final class ChatViewModelTests: XCTestCase {

    private var viewModel: ChatViewModel!
    private var mockLLMService: MockLLMService!

    override func setUp() {
        super.setUp()
        // Before each test, create a new mock service and a new ViewModel instance.
        mockLLMService = MockLLMService()
        viewModel = ChatViewModel(llmService: mockLLMService)
    }

    override func tearDown() {
        viewModel = nil
        mockLLMService = nil
        super.tearDown()
    }

    /// Tests the successful flow of sending a message and receiving a response.
    func testSendMessage_WhenSuccessful_AppendsUserAndAssistantMessages() async {
        // 1. Arrange
        let initialMessageCount = viewModel.messages.count
        let testInput = "This is a test"
        viewModel.userInput = testInput

        // 2. Act
        viewModel.sendMessage()

        // Assert that the user message is added immediately and input is cleared.
        XCTAssertEqual(viewModel.messages.count, initialMessageCount + 1)
        XCTAssertEqual(viewModel.messages.last?.content, testInput)
        XCTAssertEqual(viewModel.messages.last?.role, .user)
        XCTAssertTrue(viewModel.userInput.isEmpty, "User input should be cleared after sending.")
        XCTAssertTrue(viewModel.isLoading, "ViewModel should be in a loading state.")

        // Use an expectation to wait for the async response to be processed.
        let expectation = XCTestExpectation(description: "Wait for assistant response")
        // We check every 100ms if the loading state has been reset.
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            if self?.viewModel.isLoading == false {
                expectation.fulfill()
                timer.invalidate()
            }
        }
        await fulfillment(of: [expectation], timeout: 2.0) // 2-second timeout

        // 3. Assert
        XCTAssertFalse(viewModel.isLoading, "ViewModel should not be in a loading state after completion.")
        XCTAssertEqual(viewModel.messages.count, initialMessageCount + 2, "Should have user message and assistant response.")
        XCTAssertEqual(viewModel.messages.last?.role, .assistant, "The last message should be from the assistant.")
        XCTAssertTrue(viewModel.messages.last?.content.contains(testInput) ?? false, "Assistant response should contain original user message.")
    }

    /// Tests that the sendMessage function does nothing if the user input is empty or just whitespace.
    func testSendMessage_WithEmptyInput_DoesNothing() {
        // 1. Arrange
        let initialMessageCount = viewModel.messages.count
        viewModel.userInput = "   " // Whitespace only

        // 2. Act
        viewModel.sendMessage()

        // 3. Assert
        XCTAssertEqual(viewModel.messages.count, initialMessageCount, "Message count should not change for empty input.")
        XCTAssertFalse(viewModel.isLoading, "Should not enter loading state for empty input.")
    }
}
