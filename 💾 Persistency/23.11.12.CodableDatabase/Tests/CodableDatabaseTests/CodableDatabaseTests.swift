import XCTest
@testable import CodableDatabase

final class DatabaseTestsBis: XCTestCase {
    
    struct Todo: Persistable, Equatable {
        let id: UUID
        var name: String
        
        init(id: UUID = UUID(), name: String) {
            self.id = id
            self.name = name
        }
    }
    
    var db: Database!
    
    override func setUp() {
        db = Database(path: "tests")
    }

    override func tearDown() async throws {
        try db.destroy()
        db = nil
    }

    func test_create() throws {
        let todo = Todo(name: "Make coffee")
        try! db.upsert(todo)
        let item: Todo? = db.read(id: todo.id)
        XCTAssertEqual(item, todo)
    }

    func test_read() throws {
        let todo = Todo(name: "Make laundry")
        try? db.upsert(todo)
        let items: [Todo] = db.read()
        print(items)
        XCTAssertEqual(items, [todo])
    }
    
    func test_readItem() throws {
        let todo = Todo(name: "Make chocolate")
        try db.upsert(todo)
        let item: Todo? = db.read(id: todo.id)
        XCTAssertEqual(item, todo)
    }

    func test_update() throws {
        var todo = Todo(name: "Make coffee")
        try db.upsert(todo)
        var item: Todo? = db.read(id: todo.id)
        XCTAssertEqual(item?.name, "Make coffee")
        todo.name = "Make 20 coffees"
        try db.upsert(todo)
        item = db.read(id: todo.id)
        XCTAssertEqual(item?.name, "Make 20 coffees")
    }

    func test_delete() throws {
        let todo = Todo(name: "Make coffee")
        try db.upsert(todo)
        db.delete(todo)
        let item: Todo? = db.read(id: todo.id)
        XCTAssertNil(item)
    }

    func test_delete_all() throws {
        let todo = Todo(name: "Make coffee")
        try db.upsert(todo)
        let _: [Todo] = db.deleteAll()
        let item: Todo? = db.read(id: todo.id)
        XCTAssertNil(item)
    }
}


