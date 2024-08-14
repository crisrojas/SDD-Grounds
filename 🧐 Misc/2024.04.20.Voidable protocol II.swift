
// Helpers: 
extension Int {
	init(_ bool: Bool) {
		self = bool ? 1 : 0
	}
}

// Protocol
protocol Voidable {}

extension Int: Voidable {}
extension Double: Voidable {}
extension String: Voidable {}
extension Bool: Voidable {}

// MAJ: Api
enum VoidableHelpers {
	struct Throws<T> {
		static var Void: (T) throws -> Void {{(t:T) in }}
		static var String: (T) throws -> String {{(t:T) in ""}}
		static var Int: (T) throws -> Int {{(t:T) in 0}}
		static var Double: (T) throws -> Double {{(t:T) in 0 }}
		static var Bool: (T) throws -> Bool {{(t:T) in true}}
	}
	
	struct Async<T> {
		static var Throws: VoidableHelpers.AsyncThrows<T>.Type {VoidableHelpers.AsyncThrows<T>.self}
		static var Void: (T) async -> Void {{(t:T) in }}
		static var String: (T) async -> String {{(t:T) in ""}}
		static var Int: (T) async -> Int {{(t:T) in 0}}
		static var Double: (T) async -> Double {{(t:T) in 0 }}
		static var Bool: (T) async -> Bool {{(t:T) in true}}
	}
	
	struct AsyncThrows<T> {
		static var Void: (T) async throws -> Void {{(t:T) in }}
		static var String: (T) async throws -> String {{(t:T) in ""}}
		static var Int: (T) async throws -> Int {{(t:T) in 0}}
		static var Double: (T) async throws -> Double {{(t:T) in 0 }}
		static var Bool: (T) async throws -> Bool {{(t:T) in true}}
	}
}

extension Voidable {
	static var Void: (Self) -> Void { {(p:Self) in } }
	
	static var Async: VoidableHelpers.Async<Self>.Type {VoidableHelpers.Async<Self>.self}
	static var Throws: VoidableHelpers.Throws<Self>.Type {VoidableHelpers.Throws<Self>.self}
	static func optionalType<T>() -> (Self) -> T? {{(p: Self) in nil }}
	
	// Swift Primitives
	static var String: (Self) -> String { {(p: Self) in "" }}
	static var Int: (Self) -> Int { {(p: Self) in 0 }}
	static var Double: (Self) -> Double { {(p: Self) in 0 }}
	static var Bool: (Self) -> Bool { {(p: Self) in true }}
	
	static var OptionalString: (Self) -> String? { Self.optionalType() }
	static var OptionalInt: (Self) -> Int? { Self.optionalType() }
	static var OptionalDouble: (Self) -> Double? { Self.optionalType() }
	static var OptionalBool: (Self) -> Bool? { Self.optionalType() }
}

// MIN Api
extension Voidable {
	static var void: (Self) -> Void { {(p:Self) in } }
	
	static var async: VoidableHelpers.Async<Self>.Type {VoidableHelpers.Async<Self>.self}
	static var `throws`: VoidableHelpers.Throws<Self>.Type {VoidableHelpers.Throws<Self>.self}
	
	// Swift Primitives
	static var string: (Self) -> String { {(p: Self) in "" }}
	static var int: (Self) -> Int { {(p: Self) in 0 }}
	static var double: (Self) -> Double { {(p: Self) in 0 }}
	static var bool: (Self) -> Bool { {(p: Self) in true }}
	
	static var optionalString: (Self) -> String? { Self.optionalType() }
	static var optionalInt: (Self) -> Int? { Self.optionalType() }
	static var optionalDouble: (Self) -> Double? { Self.optionalType() }
	static var optionalBool: (Self) -> Bool? { Self.optionalType() }
}

// MAJ: Api
extension VoidableHelpers.Throws {
	
	static var void: (T) throws -> Void {{(t:T) in }}
	static var string: (T) throws -> String {{(t:T) in ""}}
	static var int: (T) throws -> Int {{(t:T) in 0}}
	static var double: (T) throws -> Double {{(t:T) in 0 }}
	static var bool: (T) throws -> Bool {{(t:T) in true}}
}

extension VoidableHelpers.Async {
	static var `throws`: VoidableHelpers.AsyncThrows<T>.Type {VoidableHelpers.AsyncThrows<T>.self}
	static var void: (T) async -> Void {{(t:T) in }}
	static var string: (T) async -> String {{(t:T) in ""}}
	static var int: (T) async -> Int {{(t:T) in 0}}
	static var double: (T) async -> Double {{(t:T) in 0 }}
	static var bool: (T) async -> Bool {{(t:T) in true}}
}

extension VoidableHelpers.AsyncThrows {
	static var void: (T) async throws -> Void {{(t:T) in }}
	static var string: (T) async throws -> String {{(t:T) in ""}}
	static var int: (T) async throws -> Int {{(t:T) in 0}}
	static var double: (T) async throws -> Double {{(t:T) in 0 }}
	static var bool: (T) async throws -> Bool {{(t:T) in true}}
}

final class ClosuresOwner {
	
	// Closures
	var processString = String.async.void
	var processInt = Int.async.throws.string
	var processBool = Bool.void
}

let owner = ClosuresOwner()
owner.processString = { print($0) }

await owner.processString("hello world")

owner.processInt = { "Processed the int: \($0)" }
let r = try await owner.processInt(3)
print(r)

owner.processBool = { print(Int($0)) }
owner.processBool(true)


final class SomeClass {
	var stringProcessor: ((String) -> Void)?
	var stringProcessor2 = String.void
}