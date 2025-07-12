//
//  KeychainServiceTests.swift
//  PolyAid
//
//  Created by Benjamin Chen on 7/7/25.
//


import XCTest
@testable import PolyAid // Import the PolyAid module to access its classes

final class KeychainServiceTests: XCTestCase {

    // The service instance we will test.
    private var keychainService: KeychainService!
    // A unique service name to avoid conflicts with other tests or real data.
    private let testService = "com.polyad.testService"

    // This method is called before each test runs.
    override func setUp() {
        super.setUp()
        keychainService = KeychainService()
        // Ensure a clean state by deleting any lingering test data before each test.
        _ = keychainService.delete(for: testService)
    }

    // This method is called after each test completes.
    override func tearDown() {
        // Clean up by deleting the test data after each test.
        _ = keychainService.delete(for: testService)
        keychainService = nil
        super.tearDown()
    }

    // Test the full lifecycle: save, retrieve, and verify the key.
    func testSaveAndRetrieveSuccessfully() {
        let apiKey = "test-api-key-12345"

        // 1. Save the key
        let saveResult = keychainService.save(apiKey: apiKey, for: testService)
        XCTAssertNoThrow(try saveResult.get(), "Saving should not throw an error.")

        // 2. Retrieve the key
        let retrieveResult = keychainService.retrieve(for: testService)
        let retrievedKey = try? retrieveResult.get()

        // 3. Verify
        XCTAssertNotNil(retrievedKey, "Retrieved key should not be nil.")
        XCTAssertEqual(retrievedKey, apiKey, "Retrieved key should match the saved key.")
    }

    // Test that retrieving a key that doesn't exist returns nil without an error.
    func testRetrieveNonExistentKeyReturnsNil() {
        let result = keychainService.retrieve(for: "non-existent-service")
        let key = try? result.get()
        XCTAssertNil(key, "Retrieving a non-existent key should result in nil.")
    }

    // Test that saving a new key for an existing service updates the original key.
    func testSaveUpdatesExistingKey() {
        let initialApiKey = "initial-key"
        let updatedApiKey = "updated-key-67890"

        // 1. Save initial key
        _ = keychainService.save(apiKey: initialApiKey, for: testService)

        // 2. Save updated key for the same service
        let updateResult = keychainService.save(apiKey: updatedApiKey, for: testService)
        XCTAssertNoThrow(try updateResult.get(), "Updating the key should not throw an error.")

        // 3. Retrieve and verify the updated key
        let retrieveResult = keychainService.retrieve(for: testService)
        let retrievedKey = try? retrieveResult.get()
        XCTAssertEqual(retrievedKey, updatedApiKey, "Retrieved key should be the updated one.")
    }

    // Test the deletion functionality.
    func testDeleteRemovesKey() {
        let apiKey = "key-to-be-deleted"

        // 1. Save a key
        _ = keychainService.save(apiKey: apiKey, for: testService)

        // 2. Verify it's there
        var retrievedKey = try? keychainService.retrieve(for: testService).get()
        XCTAssertNotNil(retrievedKey, "Key should exist before deletion.")

        // 3. Delete the key
        let deleteResult = keychainService.delete(for: testService)
        XCTAssertNoThrow(try deleteResult.get(), "Deletion should not throw an error.")

        // 4. Verify it's gone
        retrievedKey = try? keychainService.retrieve(for: testService).get()
        XCTAssertNil(retrievedKey, "Key should be nil after deletion.")
    }
}