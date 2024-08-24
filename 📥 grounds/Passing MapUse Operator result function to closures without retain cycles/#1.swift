import Foundation

final class Service1 {
	
	func fetch(completion: @escaping (String) -> Void) {
		sleep(2)
		completion("hello")
	}
	
	func fetch(string: String, _ completion: @escaping (Int) -> Void) {
		sleep(2)
		completion(string.count)
	}
	
	func fetch(int: Int, _ completion: @escaping (String) -> Void) {
		sleep(2)
		completion("is pair: \(int % 2 == 0)")
	}
	
	func fetchCascade(completion: @escaping (String) -> Void)  {
		fetch { [weak self] string in
			self?.fetch(string: string) { int in 
				self?.fetch(int: int) { completion($0) }
			}
		}
	}
	
	func fetchCascadeBis(completion: @escaping (String) -> Void) {
		// weak self
		(fetch(string:_:) ~> fetch(int:_:))("hello", completion)
	}
}

let service = Service1()
let chained = service.fetch(string:_:) ~> service.fetch(int:_:)

chained("hello") {
	print($0)
}

typealias OnParamFunction<T> = (T) -> Void
typealias OneParamAsyncFunction<P, T> = (P, @escaping OnParamFunction<T>) -> Void

func ~><A, B, C>(lhs: @escaping OneParamAsyncFunction<A, B>, rhs: @escaping OneParamAsyncFunction<B, C>) -> OneParamAsyncFunction<A, C> {
	return { a, completion in
		lhs(a) { b in 
			rhs(b) { c in 
				completion(c)
			}
		}
	}
}