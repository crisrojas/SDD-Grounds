import SwiftUI

struct Cell: View {
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


struct ContentView: View {
    @State var action: Cell.Action?
    
    var customBinding: Binding<Cell.Action?> {
        .init(
            get: { action }, 
            set: { log() ; action = $0 }
        )
    }
    var body: some View {
        VStack {
            Cell(index: 0, action: customBinding)
        }
    }
    
    func log() {}
}
