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
