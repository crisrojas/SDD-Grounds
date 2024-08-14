import SwiftUI

struct Cell: View {
	
	let index: Int
	let onEvent: (Action) -> Void
	
	enum Action {
		case check(Int)
		case delete(Int)
	}
	
	var body: some View {
		HStack {
			Image(systemName: "square")
				.onTapGesture { onEvent(.check(index)) }
			Text("Cell \(index)")
			Spacer()
			Image(systemName: "trash")
				.onTapGesture { onEvent(.delete(index)) }
		}
	}
}

// is shnorter than:

struct CellB: View {
	
	let index: Int
	
	let onCheck : (Int) -> Void
	let onDelete: (Int) -> Void
	
	enum Action {
		case check(Int)
		case delete(Int)
	}
	
	var body: some View {
		HStack {
			Image(systemName: "square")
				.onTapGesture { onCheck(index) }
			Text("Cell \(index)")
			Spacer()
			Image(systemName: "trash")
				.onTapGesture { onDelete(index) }
		}
	}
}

// what about this?:

struct CellC: View {
	
	let index: Int
	@Binding var action: Action?
	
	enum Action {
		case check(Int)
		case delete(Int)
	}
	
	var body: some View {
		HStack {
			Image(systemName: "square")
				.onTapGesture { action = .check(index) }
			Text("Cell \(index)")
			Spacer()
			Image(systemName: "trash")
				.onTapGesture { action = .delete(index) }
		}
	}
}