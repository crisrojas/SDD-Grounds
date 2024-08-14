import Foundation

struct CustomType {}
struct OtherType {}
struct AnotherType {}

// https://stackoverflow.com/questions/35046724/check-if-variable-is-a-block-function-callable-in-swift

struct MyObject {
    var str: String = ""
    var int: Int = 0
    var voidCs: (() -> Void)? = {}
    var voidOptionalCls: (() -> Void)? = nil
    var intcs: (Int) -> Void = { _ in }
    var intcsbool: (Int) -> Void = { _ in }
    var otherexample: (CustomType, OtherType, AnotherType) -> AnotherType = { _,_,_ in fatalError("") }
}

let myObject = MyObject()


func isClosure<T>(_ foo: T) -> Bool {
    //return String(foo.dynamicType).containsString("->")
    return String(describing: type(of: foo)).contains("->")
}

print(isClosure(myObject.voidCs))