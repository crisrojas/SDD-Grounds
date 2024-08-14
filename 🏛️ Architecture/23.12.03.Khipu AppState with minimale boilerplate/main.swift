//
//  KhipuCud.swift
//  Effin
//
//  Created by Cristian Felipe Patiño Rojas on 03/12/2023.
// #architecture #khipu #unidirectional

import Foundation

/*

The goal of this playground is to find the minimal boilerplate way of implementing *Khipu's architecture* AppState updating, so we avoid the repetion that usually is involved with the `update` method.

So ideally we want a simplified, generic api that handles all the crud actions associated to `AppState` update.

Something like:

```swift
state.update(\.todos, .delete(todo))

Or even better, making the code smart enough so we don't need to pass a keypath so we are able to infer directly from the type:

```swift
state.update(.delete(todo))
```

For now I've implement only the first api, though I feel the second could be implemented the way I implemented a generic codable database.
```
*/

enum Command<T: Identifiable> {
    case upsert(T)
    case delete(T.ID)
}

struct AppState {
    // Our state is usually composed by different collections of identifiable items:
    fileprivate(set) var todos    = [ToDo]()
    fileprivate(set) var projects = [Project]()
}


extension AppState {
    func updating<T: Identifiable>(_ keyPath: WritableKeyPath<Self, [T]>, with cmd: Command<T>) -> Self {
        var copy = self
        copy[keyPath: keyPath].handle(cmd)
        return copy
    }
}

extension Array where Element: Identifiable {
    mutating func handle(_ command: Command<Element>) {
        switch command {
        case .upsert(let item):
            self = filter { $0.id != item.id } + [item]
        case .delete(let id):
            self = filter { $0.id != id }
        }
    }
}


/*
Could work too if use dictionnaries instead:
*/

struct AppStateDict {
    fileprivate(set) var todos    = [UUID: ToDo]()
    fileprivate(set) var projects = [UUID: Project]()
}

extension AppStateDict {
    func updating<T>(_ keyPath: WritableKeyPath<Self, [UUID: T]>, with cmd: Command<T>) -> Self where T: Identifiable, T.ID == UUID {
        var copy = self
        copy[keyPath: keyPath].handle(cmd)
        return copy
    }
}

extension Dictionary where Key == UUID, Value: Identifiable, Value.ID == UUID {
    mutating func handle(_ cmd: Command<Value>) {
        switch cmd {
            case .upsert(let item): self[item.id] = item
            case .delete(let id)  : self[id] = nil
        }
    }
}


final class AppStateTests: XCTest {
    
    @objc 
    func test_app_state_array() {
        var sut = AppState()
        let todo = ToDo(name: "Do laundry")
        sut = sut.updating(\.todos, with: .upsert(todo))
        let first = sut.todos.first
        
        XCTAssertEqual(first, todo)
        
        sut = sut.updating(\.todos, with: .delete(todo.id))
        
        XCTAssert(sut.todos.isEmpty)
    }
    
    @objc
    func test_app_state_dictionnary() {
        var sut = AppStateDict()
        let todo = ToDo(name: "Do something")
        sut = sut.updating(\.todos, with: .upsert(todo))
        let first = sut.todos.first!.value
        
        XCTAssertEqual(first, todo)
        
        sut = sut.updating(\.todos, with: .delete(todo.id))
        
        XCTAssert(sut.todos.isEmpty)
    }
}

AppStateTests().run()