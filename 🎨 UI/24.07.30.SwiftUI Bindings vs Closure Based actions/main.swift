import SwiftUI

// I once read in Reddit that in SwiftUI we should use binding mechanism to trigger actions instead of closure based
// Not sure if it really constitues a huge benefit 
// (though, we do gain some readability and it feels indeed more fitting to SwiftUI).
// Anywas, this is a small playground about the rationale of using such mechanism.


// First we start with our closure based cell:
struct Cell_closure_based: View {
	
	let id: UUID
	
	// We only have two methods
	// but this list could be way bigger depending on our needs.
	// Which will not scalate well since we'll need to pass
	// a potentially big list of methods to the init
	let onCheck : (UUID) -> Void
	let onDelete: (UUID) -> Void

	var body: some View {
		HStack {
			Image(systemName: "square")
				.onTapGesture { onCheck(id) }
			Text("Cell \(id)")
			Spacer()
			Image(systemName: "trash")
				.onTapGesture { onDelete(id) }
		}
	}
}

// So lets take a look at one strategy we can use
// to reduce maUUIDenance problems when growing our actions list:
struct Cell_closure_based_with_enum: View {
	
	// We could simply model the view actions with an enum
	enum Action {
		case check(UUID)
		case delete(UUID)
	}
	
		
	// Then we'll have a single closure
	// able to handle that enum
	// This way we don't need to grow our list of closures, but the enum
	let onEvent: (Action) -> Void

	let id: UUID
	
	var body: some View {
		HStack {
			Image(systemName: "square")
				.onTapGesture { onEvent(.check(id)) }
			Text("Cell \(id)")
			Spacer()
			Image(systemName: "trash")
				.onTapGesture { onEvent(.delete(id)) }
		}
	}
}

// The final approach, is using a binding to tell the parent view
// it needs to handle the action:
struct Cell_SwiftUI_binding_based: View {
	
	let id: UUID
	@Binding var action: Action?
	
	enum Action: Equatable {
		case check(UUID)
		case delete(UUID)
	}
	
	var body: some View {
		HStack {
			Image(systemName: "square")
				.onTapGesture { action = .check(id) }
			Text("Cell \(id)")
			Spacer()
			Image(systemName: "trash")
				.onTapGesture { action = .delete(id) }
		}
	}
}

// Example of consuming:

struct Parent: View {
	
	@State var cellAction: Cell.Action?
	@State var model = [UUID]()
	var body: some View {
		List(model, id: \.self) { id in 
			Cell(id: id, action: $cellAction)
		}
		.onChange(of: cellAction) { 
			switch $0 {
				case .check(let id): print("Should check \(id)")
				case .delete(let id): print("Should delete \(id)")
				default: break
			}
		}
	}
}

typealias Cell = Cell_SwiftUI_binding_based