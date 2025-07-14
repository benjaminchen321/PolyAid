import SwiftUI

struct ContentView: View {
	@StateObject private var chatViewModel: ChatViewModel
	
	init() {
		// --- MODIFICATION START ---
		// Switch from the mock service to the live OpenAI service.
		// The rest of the app will now use the real implementation.
		let liveService = OpenAIService()
		_chatViewModel = StateObject(wrappedValue: ChatViewModel(llmService: liveService))
		// --- MODIFICATION END ---
	}
	
	var body: some View {
		// The NavigationStack is needed to properly display the toolbar.
		NavigationStack {
			ChatView(viewModel: chatViewModel)
				.frame(minWidth: 400, minHeight: 300)
		}
	}
}
