/*
	This is the evolution of the protocols described here: [[23.11.19.Entities map & keypath]].
	I'm really happy with the simplicity of the following apis, since it optionally removes the need for protocol conformance when configuing an object
*/
	
infix operator *: AdditionPrecedence
func *<T>(lhs: T, rhs: (inout T) -> Void) -> T {
	var copy = lhs
	rhs(&copy)
	return copy
}

/* 
	This allows us to configure objects on instantiation like this:
*/
struct SomeObject {
	var someProperty = "some value"
	var someOtherProp = 0
}

let object_1 = SomeObject() * { $0.someProperty = "new value" }

print(object_1.someProperty == "new value")

/*
	We can chain transformations if we want, though not sure if it makes so much sense as we can simply configure all
	needed values within the first closure:
*/

let object_2 = SomeObject() 
* { $0.someProperty = "some property new vlaue" }
* { $0.someOtherProp = 30 }

print(object_2.someOtherProp == 30)
	
/*

	We can simplify even more the api by removing parenthesis and operator, basically this is the wnated api:

	let object = SomeObject { $0.someProperty = "new value" }

	We can achieve it by having a default init that takes a transforming closure. 
	Though having to conform our types each time can be cumbersome and not worth it.
	With operator we can achieve the same result...
*/
protocol Initiable {init()}
extension Initiable {
	init(transform: (inout Self) -> Void) {
		var copy = Self.init()
		transform(&copy)
		self = copy
	}
}

extension SomeObject: Initiable {}

let object_3 = SomeObject { $0.someProperty = "new value" }

print(object_3.someProperty == "new value")

/* 

	We could probably achieve even more simplicity by removing the $0 and using only keypath: 

	let ... = SomeObject { \.someProperty * "new value" }
	
	Through result builders, though I have not tested and I'm not sure is it worth.
*/