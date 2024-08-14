import Foundation

enum FileHandler {
    static var jsonDecoder = JSONDecoder()
    static var jsonEncoder = JSONEncoder()
    static var fileManager = FileManager.default
    
    static func write<C: Codable>(_ codable: C, to path: String) throws {
        #if DEBUG
        jsonEncoder.outputFormatting = .prettyPrinted
        #endif
        
        let data = try jsonEncoder.encode(codable)
        try data.write(to: fileURL(path: path))
    }
    
    static func read(_ path: String) throws -> Data? {
        let url = fileURL(path: path)
        return try Data(contentsOf: url)
    }

    static func read(_ path: String) throws -> String? {
        let url = fileURL(path: path)
        return try String(decoding: Data(contentsOf: url), as: UTF8.self)
    }
    
    static func destroy(_ path: String) throws {
        try fileManager.removeItem(atPath: fileURL(path: path).path)
    }
    
    static func fileURL(path: String) -> URL {
        URL(string: "file://" + fileManager.currentDirectoryPath.replacingOccurrences(of: " ", with: "%20"))!.appendingPathComponent(path)
    }

}