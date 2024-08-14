//
//  Using csv for persisting data.swift
//  PlaygroundsTests
//
//  Created by Cristian Patiño Rojas on 23/11/23.
//

/*
    I read an article from Paul Hudson [^1] about using the URL api for reading lines and I thought that it would be cool to have a CSV based data api.
    Of course, it won't be practical for nested objecs, but anyways...
*/
protocol EncodableCSV {
    func encode() -> String
}

protocol DecodableCSV {
    static func decode(data: String) -> Self? 
}

typealias CodableCSV = DecodableCSV & EncodableCSV

final class CSVDecoder {
    func decode<T:DecodableCSV>(_ type: T.Type, from data: String) -> T? {
        type.decode(data: data)
    }
}

final class CSVEncoder {
    func encode<T: EncodableCSV>(_ value: T) -> String { 
        value.encode()
    }
}

// MARK: - Default implementations
/*
    I wasn't brave/skilled enough to implement this, but [this guy was](https://github.com/dehesa/CodableCSV)
*/
extension DecodableCSV {
    func decode(data: String) -> Self? {nil}
}

extension EncodableCSV {
    func encode() -> String {
        let mirror = Mirror(reflecting: self)
        let propertyValues = mirror.children.map { (label: String?, value: Any) in
            return "\(value)"
        }
        return propertyValues.joined(separator: ",")
    }
}

// MARK: - Tests
import Foundation
struct Todo {
    let id: UUID
    let description: String
    let isDone: Bool
}

extension Todo: CodableCSV {
    // We have to provide a custom decoding because I didn't implement the default:
    static func decode(data: String) -> Self? {
        let fields = data.components(separatedBy: ",")
        guard fields.count == 3 else { return nil }
        guard let id = UUID(uuidString: fields[0]), let isDone = Bool(fields[2]) else { return nil }
        return .init(
            id: id, 
            description: fields[1], 
            isDone: isDone
        )
    }
}

extension Todo: Equatable {}

// MARK: - Test 1
let todo = Todo(id: UUID(), description: "some description", isDone: false)
let encoded = CSVEncoder().encode(todo)
let decoded = CSVDecoder().decode(Todo.self, from: encoded)

assert(decoded == todo, "Decoded value is equal to original item")



/*
[^1]: https://www.hackingwithswift.com/articles/241/how-to-fetch-remote-data-the-easy-way-with-url-lines
*/
