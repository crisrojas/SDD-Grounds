import Foundation


enum CodablePersistencyManager {
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
    
    static func read<C: Codable>(_ path: String) throws -> C? {
      try Self.jsonDecoder.decode(C.self, from: try Data(contentsOf: fileURL(path: path)))
    }
    
    static func destroy(_ path: String) throws {
        try fileManager.removeItem(atPath: fileURL(path: path).path)
    }
    
    static func fileURL(path: String) throws -> URL {
        URL(string: "file://" + fileManager.currentDirectoryPath.replacingOccurrences(of: " ", with: "%20"))!.appendingPathComponent(path)
    }

// Use this on apps:
//  static func fileURL(path: String) throws -> URL {
//      try FileManager.default
//          .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
//          .appendingPathComponent(path)
//  }
}

struct User: Codable {
    let id: UUID
    let firstName: String
    let lastName: String
    
    init(firstName: String, lastName: String) {
        id = UUID()
        self.firstName = firstName
        self.lastName = lastName
    }
}


func saveUsers() {
    let users = Array(0...10).map { _ in
        User(
            firstName: randomizeFirstName(),
            lastName: randomizeLastName()
        )
    }
    
    
    try? CodablePersistencyManager.write(users, to: "Users.json")
}    

// saveUsers()
let users: [User]? = try? CodablePersistencyManager.read("Users.json")
print(users)
