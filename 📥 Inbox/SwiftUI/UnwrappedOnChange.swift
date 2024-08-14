import SwiftUI

// Extensión de View para añadir un modificador personalizado de onChange
extension View {
    func onChangeUnwrapped<Value: Equatable>(
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

struct Cell: View {
    let index: Int
    @Binding var action: Action?

    enum Action: Equatable {
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

struct ContentView: View {
    @State private var selectedAction: Cell.Action?

    var body: some View {
        VStack {
            Cell(index: 0, action: $selectedAction)
            Cell(index: 1, action: $selectedAction)
        }
        .onChangeUnwrapped(of: selectedAction) { action in
            handleCellAction(action)
            selectedAction = nil // Reiniciar el estado
        }
    }

    func handleCellAction(_ action: Cell.Action) {
        switch action {
        case .check(let index):
            print("Checked \(index)")
        case .delete(let index):
            print("Deleted \(index)")
        }
    }
}

