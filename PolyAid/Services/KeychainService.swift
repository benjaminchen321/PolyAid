import Foundation
import Security

/// A service class to securely store, retrieve, and delete sensitive data
/// like API keys from the macOS Keychain.
final class KeychainService {

    /// Saves an API key to the Keychain for a specific service provider.
    /// If a key already exists for the service, it will be updated.
    ///
    /// - Parameters:
    ///   - apiKey: The API key string to be stored.
    ///   - service: A unique identifier for the service (e.g., "OpenAI", "Gemini").
    /// - Returns: A `Result` type indicating success (`Void`) or a `PolyAidError`.
    func save(apiKey: String, for service: String) -> Result<Void, PolyAidError> {
        // Convert the API key string to a Data object for Keychain storage.
        guard let data = apiKey.data(using: .utf8) else {
            return .failure(.unknownError(context: "Failed to encode API key to UTF-8 data."))
        }

        // The query to find an existing item for the given service.
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "PolyAidAPIKey" // A common account name for our app's keys
        ]

        // The attributes to update or add, including the API key data.
        let attributes: [String: Any] = [
            kSecValueData as String: data
        ]

        // First, try to update an existing item.
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)

        // If no item was found to update, try to add a new one.
        if status == errSecItemNotFound {
            var newItemQuery = query
            newItemQuery[kSecValueData as String] = data
            let addStatus = SecItemAdd(newItemQuery as CFDictionary, nil)

            // If adding the new item fails, return a specific keychain error.
            if addStatus != errSecSuccess {
                return .failure(.keychainError(status: addStatus))
            }
        } else if status != errSecSuccess {
            // If the update operation failed for any other reason, return the error.
            return .failure(.keychainError(status: status))
        }

        return .success(())
    }

    /// Retrieves an API key from the Keychain for a specific service provider.
    /// - Parameters:
    ///   - service: The unique identifier for the service whose key is to be retrieved.
    /// - Returns: An optional `String` containing the API key if found, otherwise `nil`.
    ///            Throws a `PolyAidError` if a Keychain error other than `errSecItemNotFound` occurs.
    func retrieve(for service: String) -> Result<String?, PolyAidError> {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "PolyAidAPIKey",
            kSecReturnData as String: kCFBooleanTrue!, // We want the data back
            kSecMatchLimit as String: kSecMatchLimitOne // We only expect one result
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        if status == errSecSuccess {
            // If successful, cast the result to Data.
            guard let data = item as? Data,
                  // Decode the Data back to a UTF-8 string.
                  let apiKey = String(data: data, encoding: .utf8)
            else {
                return .failure(.decodingError(description: "Failed to decode Keychain data into a UTF-8 string."))
            }
            return .success(apiKey)
        } else if status == errSecItemNotFound {
            // If the item is not found, it's not an error, just return nil.
            return .success(nil)
        } else {
            // For any other error, return a failure.
            return .failure(.keychainError(status: status))
        }
    }

    /// Deletes an API key from the Keychain for a specific service provider.
    ///
    /// - Parameter service: The unique identifier for the service whose key is to be deleted.
    /// - Returns: A `Result` type indicating success (`Void`) or a `PolyAidError`.
    func delete(for service: String) -> Result<Void, PolyAidError> {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "PolyAidAPIKey"
        ]

        let status = SecItemDelete(query as CFDictionary)

        // It's considered a success even if the item wasn't found to begin with.
        if status != errSecSuccess && status != errSecItemNotFound {
            return .failure(.keychainError(status: status))
        }

        return .success(())
    }
}
