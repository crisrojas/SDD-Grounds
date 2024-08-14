// 24.03.27
// #reactivity #uikit #persistence

import Foundation

/*
    Wanted api:

    ```swift
    class VC1: UITableViewController {
        var profiles = Persistence.profiles
        
        override func viewDidLoad() {
            profiles.onChange(tableView.reloadData)
        }
    }
    ```
*/
    
// This could be an @Observabe if we were using swiftui
final class CodableResource<T: Codable> {
    lazy var data: [T] = (try? read()) ?? [] { 
        didSet {
            callbacks.forEach { $0(data) }
        }
    }
    let path: String
    
    var callbacks = [([T])->Void]()
    
    fileprivate var jsonEncoder = JSONEncoder()
    fileprivate var jsonDecoder = JSONDecoder()
    fileprivate var fileManager = FileManager()
    
    
    init(_ path: String) {
        self.path = path
    }
    
    func onChange(_ completion: @escaping ([T]) -> Void) {
        callbacks.append(completion)
    }
}

extension CodableResource {
    func load() throws {
        data = try read()
    }
    
    func write() throws {
        #if DEBUG
        jsonEncoder.outputFormatting = .prettyPrinted
        #endif
        
        let data = try jsonEncoder.encode(data)
        try data.write(to: fileURL())
    }
    
    func read() throws -> [T] {
        try jsonDecoder.decode([T].self, from: try Data(contentsOf: fileURL()))
    }
    
    func destroy(_ path: String) throws {
        try fileManager.removeItem(atPath: fileURL().path)
    }
    
    
    func fileURL() throws -> URL {
        URL(string: "file://" + FileManager.default.currentDirectoryPath.replacingOccurrences(of: " ", with: "%20"))!.appendingPathComponent(path)
    /*    
    
        In the context of an app, you may want to use this instead:
        
        ```swift
        try fileManager
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent(path)
        ```
    */
    }
}

extension CodableResource where T: Identifiable {
    
    func read(id: T.ID) -> T? {
        data.first(where: {$0.id == id})
    }
    
    func upsert(_ element: T) {
        data = data.filter { $0.id != element.id } + [element] as! [T]
        try? write()
    }
}

enum PersistenceContainer {
    static var profiles = CodableResource<Profile>("profiles.json")
}

struct Profile: Identifiable, Codable {
    let id: UUID
    let name: String
}

final class ProfilesViewController {
    var resource = PersistenceContainer.profiles
    
    func startObserving() {
        resource.onChange { _ in
            print("reload tableView")
        }
    }
}


final class AnotherViewController {
    var resource = PersistenceContainer.profiles
    
    func startObserving() {
        resource.onChange { [weak self] _ in
            print("update ui")
        }
    }
}


func test_vc_are_notified_when_upserting_item() {
    let vc1 = ProfilesViewController()
    let vc2 = AnotherViewController()
    vc1.startObserving()
    vc2.startObserving()
    
    PersistenceContainer.profiles.upsert(
        Profile(id: UUID(), name: "Pepito Ramirez")
    )
}

// Existent data
print(PersistenceContainer.profiles.data)
