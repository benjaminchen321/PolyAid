import XCTest
@testable import PolyAid

@MainActor
final class ChatViewModelTests: XCTestCase {
	
	private var viewModel: ChatViewModel!
	private var mockLLMService: MockLLMService!
	// --- MODIFICATION START ---
	private var keychainService: KeychainService!
	private let testServiceIdentifier = "OpenAI"
	// --- MODIFICATION END ---
	
	override func setUp() {
		super.setUp()
		mockLLMService = MockLLMService()
		// --- MODIFICATION START ---
		keychainService = KeychainService()
		// Clean the keychain before each test.
		_ = keychainService.delete(for: testServiceIdentifier)
		// Inject both the mock LLM service and the real keychain service.
		viewModel = ChatViewModel(llmService: mockLLMService, keychainService: keychainService)
		// --- MODIFICATION END ---
	}
	
	override func tearDown() {
		// --- MODIFICATION START ---
		_ = keychainService.delete(for: testServiceIdentifier)
		keychainService = nil
		// --- MODIFICATION END ---
		viewModel = nil
		mockLLMService = nil
		super.tearDown()
	}
	
	/// Tests the successful flow when an API key IS present.
	func testSendMessage_WithAPIKey_AppendsUserAndAssistantMessages() async {
		// 1. Arrange
		// --- MODIFICATION START ---
		// Save a dummy API key to the keychain to simulate a valid setup.
		_ = keychainService.save(apiKey: "dummy-test-key", for: testServiceIdentifier)
		// --- MODIFICATION END ---
		let testInput = "This is a test"
		viewModel.userInput = testInput
		
		// 2. Act
		viewModel.sendMessage()
		
		// Assertions for immediate UI updates
		XCTAssertEqual(viewModel.messages.count, 1)
		XCTAssertTrue(viewModel.isLoading)
		
		// Wait for async response
		let expectation = XCTestExpectation(description: "Wait for assistant response")
		Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
			if self?.viewModel.isLoading == false {
				expectation.fulfill()
				timer.invalidate()
			}
		}
		await fulfillment(of: [expectation], timeout: 2.0)
		
		// 3. Assert
		XCTAssertFalse(viewModel.isLoading)
		XCTAssertEqual(viewModel.messages.count, 2)
		XCTAssertEqual(viewModel.messages.last?.role, .assistant)
	}
	
	// --- NEW TEST ---
	/// Tests the failure flow when an API key IS NOT present.
	func testSendMessage_WithoutAPIKey_AppendsSystemErrorMessage() {
		// 1. Arrange
		// Ensure no key is saved (done in setUp).
		let testInput = "This should fail"
		viewModel.userInput = testInput
		
		// 2. Act
		viewModel.sendMessage()
		
		// 3. Assert
		// The view model should not be in a loading state as it failed pre-flight.
		XCTAssertFalse(viewModel.isLoading)
		// We should have the user's message and the system error message.
		XCTAssertEqual(viewModel.messages.count, 2)
		XCTAssertEqual(viewModel.messages.last?.role, .system)
		XCTAssertTrue(viewModel.messages.last?.content.contains("API key not found") ?? false)
	}
	// --- END NEW TEST ---
	
	func testSendMessage_WithEmptyInput_DoesNothing() {
		viewModel.userInput = "   "
		viewModel.sendMessage()
		XCTAssertEqual(viewModel.messages.count, 0)
		XCTAssertFalse(viewModel.isLoading)
	}
}
