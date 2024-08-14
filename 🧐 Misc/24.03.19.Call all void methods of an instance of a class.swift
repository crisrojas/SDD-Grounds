import Foundation

// #objc

func callAllVoidMethods(from object: AnyObject) {
    var count: UInt32 = 0
    let methods = class_copyMethodList(object_getClass(object), &count)
    
    for i in 0..<Int(count) {
        let method = methods![i]
        let selector = method_getName(method)
        if method_getNumberOfArguments(method) == 2 {
            let implementation = method_getImplementation(method)
            typealias Function = @convention(c) (AnyObject, Selector) -> Void
            let function = unsafeBitCast(implementation, to: Function.self)
            function(object, selector)
        }
    }
    
    free(methods)
}

class Class {
    @objc func method1() { print(#function + " called") }
    @objc func method2() { print(#function + " called") }
    @objc func method3() { print(#function + " called") }
    @objc func method4() { print(#function + " called") }
}

class Subclass: Class {
    @objc func method1_ofSubclass() { print(#function + " called") }
}

// Doesn't call the parent class methods
callAllVoidMethods(from: Subclass())
callAllVoidMethods(from: Class())
