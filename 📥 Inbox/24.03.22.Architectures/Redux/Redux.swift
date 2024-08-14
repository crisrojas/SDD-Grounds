import SwiftUI

/*
Elements of redux:

1. State: Represents the state of the application
2. Actions: Defines the operations that could modify the state
3. Reducer: Function that takes a given state and an action and returns a new state with the action applied
4. Store: Holds the state of the app and allows to dispatch actions
*/

// 1. State
struct AppState { 
	var count = 0
}

// 2. Actions
enum Action {
	case increment
	case decrement
}

// 3. Reducer
func reducer(state: AppState, action: Action) -> AppState { 
	var newState = state
	switch action {
		case .increment: newState.count += 1
		case .decrement: newState.count -= 1
	}
	return newState
}

// 4. Store
final class Store {
	private(set) var state: AppState
	private let reducer: (AppState, Action) -> AppState
	init(state: AppState, reducer: @escaping (AppState, Action) -> AppState) { 
		self.state = state
		self.reducer = reducer
	}
	
	func dispatch(_ action: Action) { 
		state = reducer(state, action)
	}
}

let store = Store(
	state: AppState(),
	reducer: reducer
)