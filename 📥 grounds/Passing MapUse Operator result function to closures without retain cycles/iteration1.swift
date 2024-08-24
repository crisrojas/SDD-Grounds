
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
		let map = State.init(_:)
		// 0. Classic approach
		api.fetch { [weak self] a in
			let b = State.init(a)
			self?.update(b)
		}
		
		// 1
		api.fetch { [weak self] in (map ~> self?.update)($0) }
		
		// 3
		api.fetch(_map(self, map, update))
		
		// 4
		api.fetch { [weak self] in self?.update($0) }
		
		// 5: Chaining operators 
		// This will return a mapped object instaed of the result of the fetch
		let func1 = api.fetch ~> map
		
				func1 { mapped in }
		
		let func2 = api.fetch ~> map ~> update
		
		// This will return a function with a mapped result which has been already
		// used by the function provided previously
		func2 { mappedAndAlreadyUsed in }
		
		let fetch = api.fetch ~> map ~> update ~> self
		
		// Final boss:
		// This will fetch, map result and update with mapped value only if self != nil
		fetch()
	}
	
	func update(_ result: ResultType) {
		update(.init(result))
	}
}

//typealias X = ((ResultType) -> Void) -> Void
//typealias Y = (ResultType) -> State
//typealias Z = (State) -> Void
typealias FETCH<ResultType> = (@escaping (ResultType) -> Void) -> Void

infix operator ~>: AdditionPrecedence
func ~><A, B>(
	fetch: @escaping FETCH<A>, 
	map: @escaping (A) -> B
) -> FETCH<B> {
	return { completion in
		fetch { result in
			let b = map(result)
			completion(b)
		}
	}
}


func ~><B>(fetch: @escaping FETCH<B>, use: @escaping (B) -> Void) -> FETCH<B> {
	return { completion in
		fetch { result in
			use(result)
		}
	}
}

func ~><B>(fetch: @escaping FETCH<B>, object: AnyObject) -> () -> Void {
	return { [weak object] in
		guard let _ = object else { return }
		fetch {_=$0}
	}
}

func ~><A, B>(map: @escaping (A) -> B, use: ((B) -> Void)?) -> (A) -> Void {
	return { a in
		let b = map(a)
		use?(b)
	}
}

func _map<T: AnyObject, A, B>(_ object: T, _ map: @escaping (A) -> B,_ use: @escaping (B) -> Void) -> (A) -> Void {
	return { [weak object] a in
		guard let _ = object else { return }
		let b = map(a)
		use(b)
	}
}