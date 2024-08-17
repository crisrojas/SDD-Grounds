import SwiftUI


struct ContentView: View {
    @State private var selectedAction: Cell.Action?
    
    var body: some View {
        List {
            Cell(index: 0, action: $selectedAction)
            Cell(index: 1, action: $selectedAction)
        }
        .onValueAssignment(of: selectedAction, perform: handleCellAction)
    }
}
 
extension ContentView {
    func handleCellAction(_ action: Cell.Action) {
        executeCellAction(action)
        selectedAction = nil
    }
    
    func executeCellAction(_ action: Cell.Action) {
        switch action {
            case .check(let index):
            print("Checked \(index)")
            case .delete(let index):
            print("Deleted \(index)")
        }
    }
}

struct Cell: View {
    let index: Int
    @Binding var action: Action?
    
    enum Action: Equatable {
        case check(index: Int)
        case delete(index: Int)
    }
    
    var body: some View {
        HStack {
            Image(systemName: "square")
            .onTapGesture { action = .check(index: index) }
            Text("Cell \(index)")
            Spacer()
            Image(systemName: "trash")
            .onTapGesture { action = .delete(index: index) }
        }
    }
}


// Extensión de View para añadir un modificador personalizado de onChange
extension View {
    func onValueAssignment<Value: Equatable>(
        of value: Value?,
        perform action: @escaping (Value) -> Void
    ) -> some View {
        self.onChange(of: value) { newValue in
            if let unwrappedValue = newValue {
                action(unwrappedValue)
            }
        }
    }
}
