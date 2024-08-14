//
//  Using csv for persisting data.swift
//  PlaygroundsTests
//
//  Created by Cristian Patiño Rojas on 23/11/23.
//

import Foundation

struct Todo {
    let id: UUID
    let description: String
    let isDone: Bool
}

extension Todo {
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

protocol CSVFileWritable: CodableCSV {}
extension CSVFileWritable {
    
    // We need a path to read from
    static var path: String { .init(describing: Self.self) + ".csv" }
    
    static func read() -> [Self] {
        guard let file = readFile(path: path) else { return [] }
        let entities = file.components(separatedBy: "\n")
        return entities.compactMap(Self.decode(data:))
    }
    
    static func readFile(path: String) -> String? {
        guard let path = currentURL?.appendingPathComponent(path).path
    else { return nil }
        return try? String(contentsOfFile: path, encoding: .utf8)
    }
}

extension Array where Element: CSVFileWritable {
    func write() {
        guard let url = csvURL(Element.path) else { return }
        try? self
        .map { $0.encode() }
        .reduce("", {$0 + $1 + "\n" })
        .write(to: url, atomically: true, encoding: .utf8)
    }
    
    func csvURL(_ path: String) -> URL? {
        currentURL?.appendingPathComponent(path)
    }
    
}



var currentURL = URL(string: "file://" + FileManager.default.currentDirectoryPath.replacingOccurrences(of: " ", with: "%20"))


extension Todo: CSVFileWritable {}


// MARK: - Tests
let todos = Array(0...10).map { 
    Todo(id: UUID(), description: "item \($0)", isDone: $0 % 2 == 0)
}

todos.write()
let read_todos = Todo.read()

extension Todo: Equatable {}

assert(todos == read_todos, "todos read from disk are equal to original array")