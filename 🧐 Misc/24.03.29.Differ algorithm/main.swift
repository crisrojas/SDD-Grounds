enum Differ {
    static func printDiffs<T>(_ prevState: T, _ newState: T) {
        let mirror = Mirror(reflecting: prevState)
        for (prev, current) in zip(mirror.children, Mirror(reflecting: newState).children) {
            if "\(prev.value)" != "\(current.value)" {
                print("\(prev.label ?? "") <- \(current.value)")
            }
        }
    }
}

// Usage

struct Person: Mappable {
    var fn: String
    var ln: String
    var age: Int
}

var person = Person(fn: "John", ln: "Doe", age: 32)
var newPerson = person.map { $0.age = 33 }

Differ.printDiffs(person, newPerson)