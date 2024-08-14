import SwiftUI

struct ContentView: View {
    @AppStorage("elements") var elements: [Element]?
    var body: some View {
        List {
            if let elements {
                ForEach(elements) { element in
                    Text(element.name)
                }
            } else {
                Text("No elemens found")
            }
            
            Button("Add elements") {
                elements = (elements ?? []).appending(contentsOf: makeElements())
            }
        }
    }
    
    func makeElements() -> [Element] {
        Array(0...10).map { _ in .init() }
    }
}

struct Element: Codable, Identifiable {
    var id = UUID()
    var name: String { id.uuidString }
}

extension Array {
    func appending(contentsOf array: Self) -> Self {
        var copy = self
        copy.append(contentsOf: array)
        return copy
    }
}

extension Array: RawRepresentable where Element: Codable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode([Element].self, from: data)
        else {
            return nil
        }
        self = result
    }

    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return result
    }
}
