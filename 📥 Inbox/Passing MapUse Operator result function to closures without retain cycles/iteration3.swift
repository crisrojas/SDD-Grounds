import Foundation


typealias Function<T> = (T) -> Void
typealias Completion<T> = Function<Result<T, Error>>
typealias Fetch<R, each P> = (@escaping Completion<R>, repeat each P) -> Void

struct Foo: Identifiable { let id = UUID() ; var isChecked = false }

var server =  Array(1...3).map { _ in Foo() }
class API {
	
	// With the following way of chaining functions, the closure must always be
	// placed at the begining of the function
	// Otherwise parameter packs will think of it as being a part of the apck
	func fetchFoos(_ didFetch: @escaping Completion<[Foo]>) {
		sleep(2)
		didFetch(.success(server))
	}
	
	func patchFoo(_ didFetch: @escaping Completion<Foo>, id: UUID, isChecked: Bool) {
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
	
	private let map = FooState.init(_:)

	func didLoad() {
		
		// ******************
		// Fetch foos composition:
		// ******************
		let fetchFoos = self 
		//
		// Inject self on api.fetchFoos to be weakified
		>> api.fetchFoos
		//
		// Inect function to be runned before call to api.fetchFoos
		// (so it is safe to consume self directly)
		<< {self.state = .loading}
				
		// ******************
		// Fetch foos usage
		// ******************
		fetchFoos(
			// ******************
			// Composing fetch foos closure
			// ******************
			//
			// Maps result into a state:
			map
			//
			// Updates state with such new mapped state
			// Thus triggering an update on mainQueue:
			~> update 
			//
			// Adds another function to be triggered on completion:
			~> patchFirstFoo
		)
		
	}
}

extension Controller {
	func patchFirstFoo() {
		let patch  = self >> api.patchFoo << setLoading
		if let first = state.data?.first {
			patch(didFetchFoo, first.id, true)
		}
	}
	
	func setLoading() {state = .loading}
	
	func didFetchFoo(_ result: Result<Foo, Error>) {
		dump(result.data)
	}
}

let controller = Controller()
controller.didLoad()

infix operator ~>: AdditionPrecedence
func >><A: AnyObject, R, each P>(
	object: A,
	fetch: 	@escaping Fetch<R, repeat each P>)
-> Fetch<R, repeat each P>
{
	run(fetch, weak: object)
}

func run<A: AnyObject, R, each P>(
	_ fetch: 	@escaping Fetch<R, repeat each P>,
	weak object: A
) -> Fetch<R, repeat each P>
{
	return { (completion, items: repeat each P) in
		fetch({ [weak object] result in 
			guard let _ = object else { return }
			completion(result)
		}, repeat (each items))
	}
}


precedencegroup CustomPrecedence {
	associativity: left
	higherThan: BitwiseShiftPrecedence
}
infix operator <<: CustomPrecedence
func <<<R, each P>(fetch: @escaping Fetch<R, repeat each P>, action: @escaping () -> Void) -> Fetch<R, repeat each P> {
	return { (completion, items: repeat each P) in
		action()
		fetch(completion, repeat (each items))
	}
}

func ~><A, B>(map: @escaping (A) -> B, use: @escaping (B) -> Void) -> (A) -> Void {
	return { a in
		let b = map(a)
		use(b)
	}
}

infix operator *: AdditionPrecedence
func *<T>(lhs: T, rhs: (inout T) -> Void) -> T {
	var copy = lhs
	rhs(&copy)
	return copy
}