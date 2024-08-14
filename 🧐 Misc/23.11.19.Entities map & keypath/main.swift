//
//  KeyPath mutation.swift
//  PlaygroundsTests
//
//  Created by Cristian Patiño Rojas on 19/11/23.
//
// #functional

import SwiftUI


// Allows conformers to return an updated version of themselfs
// with a mutation applied through a closure:
// someObject
//     .map { $0.someProperty    = "some value"          }
//     .map { $0.someOtherProp = "some other value" }
//
// After implementing this I found out that there was already a similar project:
// https://github.com/devxoul/Then
//
// MARK: - Mappable
protocol Mappable {}
extension Mappable {
    func map(transform: (inout Self) -> Void) -> Self {
        // We are returning a new instance so meant to be used
        // with strcuts
        var new = self
        transform(&new)
        return new
    }
}


// MARK: - KeyPathMutable
protocol KeyPathMutable {}
extension KeyPathMutable {
    func updated<V>(_ kp: WritableKeyPath<Self, V>, with value: V) -> Self {
        var copy = self
        copy[keyPath: kp] = value
        return copy
    }
    
    func makeCopy<V>(withUpdated kp: WritableKeyPath<Self, V>, _ value: V) -> Self {
        var copy = self
        copy[keyPath: kp] = value
        return copy
    }
    
    
    func with<V>(_ kp: WritableKeyPath<Self, V>, changedTo value: V) -> Self {
        var copy = self
        copy[keyPath: kp] = value
        return copy
    }
    
    func with<V>(_ kp: WritableKeyPath<Self, V>, equalTo value: V) -> Self {
        var copy = self
        copy[keyPath: kp] = value
        return copy
    }
    
    // Use for injecting dependencies:
    // SomeObject().injecting(\.dependency, Dependency())
    func injecting<V>(_ kp: WritableKeyPath<Self, V>, _ value: V) -> Self {
        var copy = self
        copy[keyPath: kp] = value
        return copy
    }
    
    func inject<V>(_ kp: WritableKeyPath<Self, V>, _ value: V) -> Self {
        var copy = self
        copy[keyPath: kp] = value
        return copy
    }
}

typealias Copiable = KeyPathMutable & Mappable
import SwiftUI

struct Person: Copiable {
    var firstName: String
    var lastName: String
}

// MARK: - Usage examples
struct MyView: View {
    
    @State var person = Person(
        firstName: "cristian",
        lastName: "patiño"
    )
    @State var firstName = ""
    @State var lastName = ""
    var body: some View {
        VStack {
            TextField("First name", text: $firstName)
            TextField("Last name", text: $lastName)
            Button("Change name") {
                
                person = person.map {
                    $0.firstName = firstName
                    $0.lastName = lastName
                }
            }
        }
    }
}

// MARK: - Tests

final class MutableProtocolsTests: XCTest {
    struct SomeObject: Copiable {
        var someValue = "initialValue"
    }
    
    @objc func test_mappable() {
        let object = SomeObject()
        .with(\.someValue, equalTo: "new value")
        
        XCTAssertEqual(object.someValue, "new value")
    }
}

MutableProtocolsTests().run()