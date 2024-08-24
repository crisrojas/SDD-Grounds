import Foundation


typealias Function<T> = (T) -> Void
typealias Completion<T> = Function<Result<T, Error>>


struct Foo: Identifiable { let id = UUID() ; var isChecked = false }

var server =  Array(1...3).map { _ in Foo() }
class API {
	
	// With the following way of chaining functions, the closure must always be
	// placed at the begining of the function
	// Otherwise parameter packs will think of it as being a part of the pack
	func fetchFoos(_ didFetch: @escaping Completion<[Foo]>) {
		sleep(2)
		didFetch(.success(server))
	}
	
	func patchFoo(id: UUID, isChecked: Bool, _ didFetch: @escaping Completion<Foo>) {
		sleep(3)
		let item = {server.filter { $0.id == id }.first!}
		server = server.filter { $0.id != id } + [item() * {$0.isChecked = true}]
		didFetch(.success(item()))
	}
}

enum State<T> {
	case idle, loading, success(T), failure(String)
}

extension State {
	init() { self = .idle }
	var data: T? {
		if case let .success(data) = self { return data }
		return nil
	}
	
	init(_ result: Result<T, Error>) {
		switch result {
			case .success(let data): self = .success(data)
			case .failure(let error): self = .failure(error.localizedDescription)
		}
	}
	
	
	func debug() {
		if data != nil { dump(self) }
		else {print(self)}
	}
}

extension Result {
	var data: Success? {
		if case let .success(data) = self { return data }
		return nil
	}
}

typealias FooState = State<[Foo]>
class Controller {
    var api = API()
	var state = FooState() { didSet {updateUI()} }
	
	func update(_ newState: FooState) {state = newState}
	
	// Updates ui on main thread
	func updateUI() {state.debug()}

	func didLoad() {
		
		state = .loading
		api.fetchFoos(weak(self, in: FooState.init(_:) ~> update ~> patchFirstFoo))
	}
}

func weak<O: AnyObject, T>(_ object: O, in action: @escaping Completion<T>) -> Completion<T> {{ [weak object] result in
	guard let _ = object else { return }
	action(result)
}}

extension Controller {
	func patchFirstFoo() {
		if let first = state.data?.first {
			state = .loading
			api.patchFoo(id: first.id, isChecked: true, weak(self, in: didFetchFoo))
		}
	}
	
	
	func didFetchFoo(_ result: Result<Foo, Error>) {
		dump(result.data)
	}
}

let controller = Controller()
controller.didLoad()

infix operator ~>: AdditionPrecedence
func ~><A, B>(map: @escaping (A) -> B, use: @escaping (B) -> Void) -> (A) -> Void {
	return { a in
		let b = map(a)
		use(b)
	}
}

// My beloved asterisk snippet to easily map any object into a modified version of itself:
infix operator *: AdditionPrecedence
func *<T>(lhs: T, rhs: (inout T) -> Void) -> T {
	var copy = lhs
	rhs(&copy)
	return copy
}