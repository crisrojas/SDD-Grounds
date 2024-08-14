import Foundation
 
protocol XCTest: AnyObject {}
extension XCTest {
	func run() {callAllVoidMethods(from: self)}
}

func callAllVoidMethods(from object: AnyObject) {
	var count: UInt32 = 0
	let methods = class_copyMethodList(type(of: object), &count)
	
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


struct XCTAssertEqual<T: Equatable> {
	init(_ f: T, _ s: T, line: UInt = #line, function: String = #function) {
		let result = f == s ? "✅" : "❌"
		print("\n" + function)
		print(String(repeating: "-", count: function.count))
		print(line.description + " " + result + " " + (f == s).description)
	}
}

struct XCTAssertNotEqual<T: Equatable> {
	init(_ f: T, _ s: T, line: UInt = #line, function: String = #function) {
		let result = f != s ? "✅" : "❌"
		print("\n" + function)
		print(String(repeating: "-", count: function.count))
		print(line.description + " " + result + " " + (f != s).description)
	}
}