import Foundation

// Playground for experimenting with bool semantics
final class MyClass {
    var loading = true
    var opening = false
    var failing = true
}

let myClass = MyClass()

extension Bool {
    var isFalse: Bool { !self }
}

extension Collection {
    var isNotEmpty: Bool { !isEmpty }
}

print(myClass.loading.isFalse)
print(myClass.opening.isFalse)
print(myClass.failing.isFalse)
print("".isNotEmpty)
print("".isEmpty.isFalse)
