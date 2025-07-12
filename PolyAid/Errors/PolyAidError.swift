import Foundation

/// A comprehensive error type for all potential failures within the PolyAid application.
/// This allows for robust error handling and clear debugging information.
enum PolyAidError: Error, LocalizedError, Equatable {
    /// Encapsulates errors related to Keychain operations.
    case keychainError(status: OSStatus)

    /// Represents a failure during the API communication process.
    case networkError(underlyingError: NSError)

    /// Indicates that the API response was not in the expected format.
    case decodingError(description: String)

    /// A generic error for situations where the specific cause is unknown or not categorized.
    case unknownError(context: String)

    /// Provides a user-friendly description for each error case.
    public var errorDescription: String? {
        switch self {
        case .keychainError(let status):
            // Provides a human-readable string for cryptic OSStatus codes.
            return "Keychain operation failed with status code: \(status). Message: \(SecCopyErrorMessageString(status, nil) ?? "Unknown error" as CFString)"
        case .networkError(let underlyingError):
            return "Network request failed: \(underlyingError.localizedDescription)"
        case .decodingError(let description):
            return "Failed to decode API response: \(description)"
        case .unknownError(let context):
            return "An unknown error occurred: \(context)"
        }
    }

    // Conformance to Equatable for testing purposes.
    static func == (lhs: PolyAidError, rhs: PolyAidError) -> Bool {
        switch (lhs, rhs) {
        case (.keychainError(let lhsStatus), .keychainError(let rhsStatus)):
            return lhsStatus == rhsStatus
        case (.networkError(let lhsError), .networkError(let rhsError)):
            return lhsError.domain == rhsError.domain && lhsError.code == rhsError.code
        case (.decodingError(let lhsDesc), .decodingError(let rhsDesc)):
            return lhsDesc == rhsDesc
        case (.unknownError(let lhsContext), .unknownError(let rhsContext)):
            return lhsContext == rhsContext
        default:
            return false
        }
    }
}
