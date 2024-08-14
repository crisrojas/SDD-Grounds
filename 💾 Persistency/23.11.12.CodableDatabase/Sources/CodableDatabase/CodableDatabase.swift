//
//  Database.swift
//  PlaygroundsTests
//
//  Created by Cristian Felipe Patiño Rojas on 13/12/2023.
//

import Foundation
protocol Persistable: Identifiable, Codable {
    var id: UUID {get}
}

class Database {
    private lazy var storage: [UUID: Data] = readFile() {didSet{try?persist()}}
    
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()
    let manager = FileManager.default
    
    let path: String
    
    init(path: String, ext: String = ".json") {
        self.path = path + ext
    }
}

// MARK: - API
extension Database {
    func read<T: Persistable>(id: UUID) -> T? {
        guard let data = storage[id] else { return nil }
        return try? decoder.decode(T.self, from: data)
    }

    func read<T: Persistable>() -> [T] {
        storage.compactMap { (_, data) in
            try? decoder.decode(T.self, from: data)
        }
    }
    
    func upsert<T: Persistable>(_ item: T) throws {
        let data = try encoder.encode(item)
        storage[item.id] = data
    }

    func delete<T: Persistable>(_ item: T) {
        storage[item.id] = nil
    }
    
    @discardableResult
    func deleteAll<T: Persistable>() -> [T] {
        (read() as [T]).forEach {
            storage[$0.id] = nil
        }
        return []
    }
}

// MARK: - File handling

extension Database {
    
    func persist() throws {
        let data = try encoder.encode(storage)
        try data.write(to: fileURL())
    }
    
    func readFile() -> [UUID: Data] {
        (try? decoder.decode([UUID:Data].self, from: try Data(contentsOf: fileURL()))) ?? [:]
    }
    
    func fileURL() throws -> URL {try desktopURL()}
    
    fileprivate func desktopURL() throws -> URL {
        try manager
            .url(for: .desktopDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent(path)
    }
    
    fileprivate func currentURL() -> URL{
        URL(string: "file://" + FileManager.default.currentDirectoryPath.replacingOccurrences(of: " ", with: "%20"))!.appendingPathComponent(path)
    }
    
    public func destroy() throws {
        let fileManager = FileManager.default
        let fileURL = try fileURL()
        
        // Verificar si el archivo existe
        guard fileManager.fileExists(atPath: fileURL.path) else {
            // El archivo no existe, no necesitamos hacer nada
            return
        }
        
        do {
            // Intentar eliminar el archivo
            try fileManager.removeItem(at: fileURL)
        } catch {
            // Manejar otros errores excepto el caso donde el archivo no existe
            throw error
        }
    }
    
}
