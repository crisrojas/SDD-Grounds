/*
	The goal of this playground is to have a way of structs with closures to conform to equatable.
	So we can do something like this without the compiler complaining:
	
	```swift
	struct Example: Equatable {
		let someProperty: String
		let someClosure: () -> Void
	}
	```
	
	The code I came up with here works to an extend by comparing any properties that are Equatable conformers, so it will ignore
	not only the closures but all the non conforming to equatable, which misses the point. It seems this isn't possible to implement...
*/
extension Equatable {
	func isEqual(_ other: any Equatable) -> Bool {
		guard let other = other as? Self else {
			return false
		}
		return self == other
	}
}

import Foundation

func isClosure<T>(_ foo: T) -> Bool {
	//return String(foo.dynamicType).containsString("->")
	return String(describing: type(of: foo)).contains("->")
}


protocol CustomEquatable: Equatable {}

extension CustomEquatable {
	static func == (lhs: Self, rhs: Self) -> Bool {
		
		let props1 = Mirror(reflecting: lhs).children.compactMap { !isClosure($0) }
		let props2 = Mirror(reflecting: rhs).children.compactMap { !isClosure($0) }
		
		guard props1.count == props2.count else { return false }
		
		var bools = [Bool]()
		
		for (lhsProperty, rhsProperty) in zip(props1, props2) {
			bools.append(lhsProperty.isEqual(rhsProperty))
		}
		
		return bools.allSatisfy { $0 }
	}
}


final class CustomEquatableTests: XCTest {
	
	@objc
	func test_instances_are_equal_even_if_different_closure() {
		
		struct Example: CustomEquatable {
			var string = "" 
			var closure: (() -> Void)? = nil
		}
		
		
		let instance1 = Example()
		let instance2 = Example { }
		
		XCTAssertEqual(instance1, instance1)
		XCTAssertEqual(instance1, instance2)
	}
	
	@objc
	func test_shouldnt_instanciate_if_non_equatable_prop() {
		
		struct CustomType {
			let someStr: String
		}
		
		
		// This shouldn't be possible
		struct Example: CustomEquatable {
			let type: CustomType
		}
		
		let instance1 = Example(type: .init(someStr: "hello world"))
		let instance2 = Example(type: .init(someStr: "different string"))
		
		XCTAssertEqual(instance1, instance2)
	}
}

CustomEquatableTests().run()