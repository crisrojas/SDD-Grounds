
struct ResultType {}
class API {
	func fetch(_ completion: @escaping (ResultType) -> Void) {
		completion(ResultType())
	}
}

struct State {}
extension State { init(_ result: ResultType) {}}
class Controller {
    var api = API()
	var state = State()
	
	func update(_ newState: State) {state = newState}
	func didLoad() {
		(self ~> api.fetch)(State.init(_:) ~> update)
	}
}

// This won't work if fetch has additionnal parameters
// So I wonder if this is any useful. Maybe we can achive a functional implementations with parameter packs.
typealias FETCH<ResultType> = (@escaping (ResultType) -> Void) -> Void
infix operator ~>: AdditionPrecedence
func ~><A: AnyObject, B>(
	object: A,
	fetch: @escaping FETCH<B>
) -> FETCH<B> {
	return { completion in
		fetch { [weak object] result in
			 guard let _ = object else { return }
			 completion(result)
		}
	}
}

func weakify<A: AnyObject, B>(_ object: A, on fetch: @escaping FETCH<B>) -> FETCH<B> {
	return { completion in
		fetch { [weak object] result in
			guard let _ = object else { return }
			completion(result)
		}
	}
}

func ~><A, B>(map: @escaping (A) -> B, use: @escaping (B) -> Void) -> (A) -> Void {
	return { a in
		let b = map(a)
		use(b)
	}
}