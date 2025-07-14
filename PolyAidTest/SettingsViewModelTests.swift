import XCTest
@testable import PolyAid

@MainActor
final class SettingsViewModelTests: XCTestCase {

    private var viewModel: SettingsViewModel!
    private var keychainService: KeychainService!
    private let testServiceIdentifier = "OpenAI"

    override func setUp() {
        super.setUp()
        keychainService = KeychainService()
        // Ensure a clean state before each test.
        _ = keychainService.delete(for: testServiceIdentifier)
        viewModel = SettingsViewModel(keychainService: keychainService)
    }

    override func tearDown() {
        // Clean up after each test.
        _ = keychainService.delete(for: testServiceIdentifier)
        viewModel = nil
        keychainService = nil
        super.tearDown()
    }

    func testInitialState_WithNoKeySaved_isKeySavedIsFalse() {
        XCTAssertFalse(viewModel.isKeySaved, "isKeySaved should be false on initial load when no key exists.")
    }

    func testSaveAPIKey_WithValidKey_UpdatesIsKeySavedAndClearsInput() {
        // 1. Arrange
        let apiKey = "my-secret-test-key"
        viewModel.openAIAPIKeyInput = apiKey

        // 2. Act
        viewModel.saveAPIKey()

        // 3. Assert
        XCTAssertTrue(viewModel.isKeySaved, "isKeySaved should be true after saving a key.")
        XCTAssertTrue(viewModel.openAIAPIKeyInput.isEmpty, "Input field should be cleared after saving.")
        XCTAssertFalse(viewModel.feedbackMessage.isEmpty, "A success feedback message should be shown.")

        // Verify directly with the keychain service.
        let retrievedKey = try? keychainService.retrieve(for: testServiceIdentifier).get()
        XCTAssertEqual(retrievedKey, apiKey)
    }

    func testDeleteAPIKey_WhenKeyExists_UpdatesIsKeySaved() {
        // 1. Arrange
        let apiKey = "key-to-delete"
        _ = keychainService.save(apiKey: apiKey, for: testServiceIdentifier)
        // Re-create the view model to ensure it loads the new state.
        viewModel = SettingsViewModel(keychainService: keychainService)
        XCTAssertTrue(viewModel.isKeySaved, "Precondition: isKeySaved should be true.")

        // 2. Act
        viewModel.deleteAPIKey()

        // 3. Assert
        XCTAssertFalse(viewModel.isKeySaved, "isKeySaved should be false after deleting the key.")
        XCTAssertFalse(viewModel.feedbackMessage.isEmpty, "A feedback message should be shown.")

        // Verify directly with the keychain service.
        let retrievedKey = try? keychainService.retrieve(for: testServiceIdentifier).get()
        XCTAssertNil(retrievedKey, "The key should be nil in the keychain after deletion.")
    }
}
