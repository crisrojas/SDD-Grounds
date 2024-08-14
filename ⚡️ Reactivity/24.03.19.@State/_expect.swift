// +++
struct Wrapper<T> { 
    let t: T
    let line: UInt
    init(_ t: T, line: UInt) {self.t = t; self.line = line}
}

infix operator << : AdditionPrecedence

// Definir la función que implementa la operación
func << (left: String, right: String) -> String {
    return left + " " + right
}

func << (left: String, right: Any) -> String {
    return left + " " + "\(right)"
}

infix operator >: AdditionPrecedence
func ><T: Numeric & Comparable>(left: Wrapper<T>, right: T) { 
    let icon = left.t > right ? "✅" : "❌"
    let result = left.t > right ? "is greater than" : "is lesser than"
    print(left.line.description << icon << left.t << result << right)
}

infix operator <: AdditionPrecedence
func <<T: Numeric & Comparable>(left: Wrapper<T>, right: T) { 
    let icon = left.t < right ? "✅" : "❌"
    let result = left.t < right ? "is lesser than" : "is greater than"
    print(left.line.description << icon << left.t << result << right)
}


func expect<T>(_ t: T, line: UInt = #line) -> Wrapper<T> {.init(t, line: line)}
//func equal<T> (_ t: T, line: UInt = #line) -> Wrapper<T> {.init(t, line: line)}

enum AssertOperator<T> { 
    case equal(T)
    case different(T)
}

extension Wrapper where T: ExpressibleByNilLiteral & Equatable {
    func toBe(_ value: T, line: UInt = #line) {
        let icon = self.t == value ? "✅" : "❌"
        let result = self.t == value ? "is equal to" : "is different from"
        print(line.description << icon << self.t << result << value)
    }
}

extension Wrapper where T: Equatable {
    func toBe(_ op: AssertOperator<T>, line: UInt = #line) { 
        switch op { 
            case .equal(let new):
            let icon = self.t == new ? "✅" : "❌"
            let result = self.t == new ? "is equal to" : "is different from"
            print(line.description << icon << self.t << result << new)
            
            case .different(let new):
            let icon = self.t != new ? "✅" : "❌"
            let result = self.t == new ? "is equal to" : "is different from"
            print(line.description << icon << self.t << result << new)
        }
    }
}

extension Wrapper where T == Bool {
    func toBe(_ bool: Bool, line: UInt = #line) {
        let icon = self.t == bool ? "✅" : "❌"
        let result = self.t == bool ? "is equal to" : "is different from"
        print(line.description << icon << self.t << result << bool)
    }
}

func equalTo<T>(_ object: T) -> AssertOperator<T> {.equal(object)}
func differentFrom<T>(_ object: T) -> AssertOperator<T> {.different(object)}

//expect("hello world").toBe(equalTo("hello world"))
//expect(1).toBe(equalTo(2))
//expect(1) > 2
//expect(1.0) > 2.0
//expect(2) < (1)

