import SwiftUI

struct AppState {
	var countA = CountState()
	var countB = CountState()
}

struct CountState {
	var count = 0
}

struct App {
	@State var state = AppState()
	
	var body: some View {
		VStack {
			CountView(state: $state.countA)
			CountView(state: $state.countB)
		}
	}
}

struct CountView: View {
	@Binding var state: CountState
	var body: some View {
		Text("text")
	}
}