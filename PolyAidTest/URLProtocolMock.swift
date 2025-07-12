import Foundation

/// A mock URLProtocol to intercept network requests for testing purposes.
/// It allows us to return canned data or errors for specific URLs without
/// making actual network calls.
final class URLProtocolMock: URLProtocol {
    // Dictionary to hold the mock data for different URLs.
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data?))?

    override class func canInit(with request: URLRequest) -> Bool {
        // We want to handle all requests.
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        // Return the original request.
        return request
    }

    override func startLoading() {
        guard let handler = URLProtocolMock.requestHandler else {
            fatalError("Handler is not set.")
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            if let data = data {
                client?.urlProtocol(self, didLoad: data)
            }
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {
        // Required override, but nothing to do.
    }
}
