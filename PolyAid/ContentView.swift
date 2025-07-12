import SwiftUI

/// The root view of the PolyAid application.
/// This view is responsible for setting up the main dependencies (the ViewModel)
/// and displaying the primary user interface.
struct ContentView: View {
    /// The single source of truth for our chat logic.
    /// We use `@StateObject` because this view "owns" the ViewModel. It creates it
    /// and ensures it persists for the lifetime of the view.
    @StateObject private var chatViewModel: ChatViewModel

    /// Custom initializer to set up the ViewModel with its dependencies.
    /// This is where we decide whether to use the Mock service or a real one.
    init() {
        // For the MVP, we instantiate the ViewModel with our MockLLMService.
        // This allows the entire UI to be interactive without any real API keys.
        let mockService = MockLLMService()
        _chatViewModel = StateObject(wrappedValue: ChatViewModel(llmService: mockService))
    }

    var body: some View {
        // Display the ChatView and pass it the ViewModel it needs to function.
        ChatView(viewModel: chatViewModel)
            .frame(minWidth: 400, minHeight: 300) // Set a reasonable default window size.
    }
}
