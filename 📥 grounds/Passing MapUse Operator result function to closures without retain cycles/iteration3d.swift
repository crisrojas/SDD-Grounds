import Foundation


typealias Function<T> = (T) -> Void
typealias Completion<T> = Function<Result<T, Error>>
typealias Async<R, each P> = (@escaping Completion<R>, repeat each P) -> Void

struct Todo: Identifiable { let id: UUID ; var isChecked = false }

var server =  Array(1...3).map { _ in Todo(id: UUID()) }
protocol API {}
extension API {
	
	// With the following way of chaining functions, the closure must always be
	// placed at the begining of the function
	// Otherwise parameter packs will think of it as being a part of the pack
	func fetchTodos(_ didAsync: @escaping Completion<[Todo]>) {
		sleep(2)
		didAsync(.success(server))
	}
	
	func patchTodo(_ didAsync: @escaping Completion<Todo>, id: UUID, isChecked: Bool) {
		sleep(3)
		server[id] = server[id] * {$0!.isChecked = true}
		didAsync(.success(server[id]!))
	}
}


struct State<T>: CustomDebugStringConvertible {
	
	typealias Value = Enum<T>
	private var value: Value
	
	subscript<U>(dynamicMember keyPath: KeyPath<Enum<T>, U>) -> U {
		return value[keyPath: keyPath]
	}
	
	subscript<U>(dynamicMember keyPath: WritableKeyPath<Enum<T>, U>) -> U {
		get { value[keyPath: keyPath] }
		set { value[keyPath: keyPath] = newValue }
	}
	
	func data() -> T? {value.data()}
	func previousData() -> T? {value.previousData()}
	func isLoading() -> Bool {value.isLoading()}
	func isSuccess() -> Bool {value.isSuccess()}
	mutating func update(_ next: Enum<T>) {
		if next.isLoading() {
			value = .loading(data())
			return
		}
		value = next
	}
	
	var debugDescription: String {"\(value)"}
}

extension State {
	init() {value = .init() }
}

extension State where T: Collection, T.Element: Identifiable {
	subscript(id: T.Element.ID) -> T.Element? {
		get { value[id] }
		set(n) { value[id] = n }
	}
}

enum _State<A> {
	case idle, loading(A? = nil), success(A), failure(String)
}

extension State {
	enum Enum<A> {
		case idle, loading(A? = nil), success(A), failure(String)
	}
}

extension State.Enum {
	func data() -> A? {
		if case let .success(data) = self { return data }
		return nil
	}
	
	func previousData() -> A? {
		if case let .loading(data) = self { return data }
		return nil
	}
	
	init(_ result: Result<A, Error>) {
		switch result {
			case .success(let data): self = .success(data)
			case .failure(let error): self = .failure(error.localizedDescription)
		}
	}
	
	func isLoading() -> Bool {
		if case .loading = self { return true }
		return false
	}
	
	func isSuccess() -> Bool { data() != nil }
}

extension State.Enum {
	init() {
		self = .idle
	}
}

extension State.Enum where A: Collection, A.Element: Identifiable {
	subscript(id: A.Element.ID) -> A.Element? {
		get { data()?.first { $0.id == id } }
		set(newValue) {
			guard let data = (data() ?? previousData()) else { return }
			let removedItem = data.filter { $0.id != id }
			if let newValue {
				let new = removedItem + [newValue]
				self = .success(new as! A)
			} else {
				self = .success(removedItem as! A)
			}
			
		}
	}
}

protocol Redux: AnyObject {
	associatedtype Model
	var state: State<Model> {get set}
	func configƒState()
}

extension Redux {
	func update(_ next: State<Model>.Value) {
		state.update(next)
	}

	func setLoading() {
		state.update(.loading())
	}
	
	func updateUI() {
		dispatchOnMainThreadIfNeeded(configƒState)
	}
}

func dispatchOnMainThreadIfNeeded(_ action: @escaping () -> Void) { 
	if Thread.isMainThread { action() }
	else { dispatch(action, on: .main) }
}

func dispatch(_ action: @escaping () -> Void, on queue: DispatchQueue) {
	queue.async { action() }
}


class TodoListViewController: API, Redux {
	@DiffLogger var state = State<[Todo]>() {
		didSet {updateUI()}
	}
	
	func configƒState() {/* implement */}

	func didLoad() {
		let map   = State<[Todo]>.Value.init(_:)
		let completion = map ~> update ~> patchFirstTodo
		let fetch = setLoading + fetchTodos - self
		
		fetch(completion)
	}
}

extension TodoListViewController {
	func patchFirstTodo() {
		if let first = state.data()?.first {
			let map = Todo.init(_:) ?? first
			let completion = map ~> upsert
			let patch = setLoading + patchTodo - self
			
			patch(completion, first.id, true)
		}
	}
	
	func upsert(_ todo: Todo) {
		state[todo.id] = todo
	}
}


extension Todo {
	init?(_ result: Result<Todo, Error>) {
		guard let value = try? result.get() else { return nil }
		self = value
	}
}


let todosVC = TodoListViewController()
todosVC.didLoad()

// Operands: both AdditionPrecedence so we can chain them from left to right
infix operator - : AdditionPrecedence
infix operator + : AdditionPrecedence
infix operator ~>: AdditionPrecedence
infix operator ??: AdditionPrecedence
func ??<A, B>(mapper: @escaping (A) -> B?, coalescedValue: B) -> (A) -> B {{ a in 
	return mapper(a) ?? coalescedValue
}}

func -<O: AnyObject, C, each P>(
	fetch: 	@escaping Async<C, repeat each P>,
	object: O)
-> Async<C, repeat each P>
{
	Weakifier.weakify(object, in: fetch)
}

enum Weakifier {
	static func weakify<Object: AnyObject, Completion, each Param>(
		_ object: Object,
		in fetch: 	@escaping Async<Completion, repeat each Param>
	) -> Async<Completion, repeat each Param>
	{
		return { (completion, items: repeat each Param) in
			let safeCompletion = Self.guardLet(object, beforeRunning: completion)
			fetch(safeCompletion, repeat (each items))
		}
	}
	
	static func guardLet<A: AnyObject, R>(_  object: A, beforeRunning completion: @escaping (R) -> Void) -> (R) -> Void {
		return { [weak object] result in
			guard let _ = object else { return }
			completion(result)
		}
	}
}


func +<R, each P>(action: @escaping () -> Void, fetch: @escaping Async<R, repeat each P>) -> Async<R, repeat each P> {
	ActionInjecter.injectAndRun(action, beforCompletionIn: fetch)
}

enum ActionInjecter {
	static func injectAndRun<R, each P>(_ action: @escaping () -> Void, beforCompletionIn function: @escaping Async<R, repeat each P>) -> Async<R, repeat each P> {
		return { (completion, items: repeat each P) in
			action()
			function(completion, repeat (each items))
		}
	}
}


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


@propertyWrapper
final class DiffLogger<T> {
	
	var wrappedValue: T  {
		didSet {logDiff(oldValue)}
	}
	
	init(wrappedValue: T) {self.wrappedValue = wrappedValue}
	
	func logDiff(_ oldValue: T) {
		// could use mirror to better logs
		print("\(oldValue) -> \(wrappedValue)")
	}
}  

extension Array where Element: Identifiable {
	subscript(id: Element.ID) -> Element? {
		get { first { $0.id == id } }
		set(newValue) {
			if let index = firstIndex(where: { $0.id == id }) {
				if let newValue = newValue {
					self[index] = newValue
				} else {
					remove(at: index)
				}
			} else if let newValue = newValue {
				append(newValue)
			}
		}
	}
}
