import SwiftUI

struct ChatView: View {
	@ObservedObject var viewModel: ChatViewModel
	// --- MODIFICATION START ---
	/// State to control the presentation of the settings sheet.
	@State private var showingSettings = false
	// --- MODIFICATION END ---
	
	var body: some View {
		VStack(spacing: 0) {
			ScrollView {
				LazyVStack(spacing: 0) {
					ForEach(viewModel.messages) { message in
						MessageView(message: message)
					}
				}
			}
			
			Divider()
			
			HStack(spacing: 12) {
				TextField("Enter your message...", text: $viewModel.userInput)
					.textFieldStyle(.plain)
					.onSubmit(viewModel.sendMessage)
				
				Button(action: viewModel.sendMessage) {
					Image(systemName: "arrow.up.circle.fill")
						.font(.title)
				}
				.buttonStyle(.borderless)
				.tint(.blue)
				.disabled(viewModel.userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isLoading)
				
				if viewModel.isLoading {
					ProgressView()
						.scaleEffect(0.8)
						.frame(width: 28, height: 28)
				}
			}
			.padding()
		}
		// --- MODIFICATION START ---
		.toolbar {
			// Add a toolbar to the top of the view.
			ToolbarItem(placement: .automatic) {
				Button(action: { showingSettings = true }) {
					Label("Settings", systemImage: "gear")
				}
			}
		}
		.sheet(isPresented: $showingSettings) {
			// Present the SettingsView as a modal sheet.
			SettingsView()
		}
		// --- MODIFICATION END ---
	}
}
