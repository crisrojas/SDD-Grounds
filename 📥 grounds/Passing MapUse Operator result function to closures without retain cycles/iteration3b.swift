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


@dynamicMemberLookup
struct StateRecord<T> {
	
	typealias Value = Enum<T>
	enum Enum<A> {
		case idle, loading, success(A), failure(String)
	}
	
	var lastKnownData: T?
	var previous: Value?
	var value: Value {
		didSet { 
			previous = oldValue
			if let data = oldValue.get() {
				lastKnownData = data
			}
		}
	}
	
	subscript<U>(dynamicMember keyPath: KeyPath<Self.Enum<T>, U>) -> U {
		return value[keyPath: keyPath]
	}
	
	subscript<U>(dynamicMember keyPath: WritableKeyPath<Self.Enum<T>, U>) -> U {
		get { value[keyPath: keyPath] }
		set { value[keyPath: keyPath] = newValue }
	}
}

extension StateRecord.Enum {
	func get() -> A? {
		if case let .success(data) = self { return data }
		return nil
	}
	
	init(_ result: Result<A, Error>) {
		switch result {
			case .success(let data): self = .success(data)
			case .failure(let error): self = .failure(error.localizedDescription)
		}
	}
}

extension StateRecord {
	init() {
		self.value = .idle
	}
	
	func get() -> T? {value.get()}
	
	init(_ value: T) {
		self.value = .success(value)
	}
	
	init(_ result: Result<T, Error>) {
		self = .init(result)
	}
}

extension StateRecord where T: Collection, T.Element: Identifiable {
	subscript(id: T.Element.ID) -> T.Element? {
		get { get()?.first { $0.id == id } }
		set(newValue) {
			guard let data = (get() ?? lastKnownData) else { return }
			let removedItem = data.filter { $0.id != id }
			if let newValue {
				let new = removedItem + [newValue]
				self.value = .success(new as! T)
			} else {
				self.value = .success(removedItem as! T)
			}
			
		}
	}
}

protocol Redux: AnyObject {
	associatedtype T
	typealias State = StateRecord<T>
	var state: State {get set}
	func viewƒState()
}

extension Redux {

	func update(_ new: StateRecord<T>.Value) {state.value = new}
	func setLoading() {state.value = .loading}
	func updateUI() {
		dispatchOnMainThreadIfNeeded(viewƒState)
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
	@StateRecordLogger var state = StateRecord<[Todo]>() { 
		didSet {updateUI()}
	}
	
	func update(_ newState: State.Value) {
		state.value = newState
	}
	
	func viewƒState() {/* implement */}
	
	func didLoad() {
		(setLoading + fetchTodos - self) (State.Value.init(_:) ~> update ~> patchFirstTodo)
	}
}

extension TodoListViewController {
	func patchFirstTodo() {
		if let first = state.get()?.first {
			let patch = setLoading + patchTodo - self
			
			patch (
				{Todo.init($0) ?? first} ~> upsert, 
				first.id, 
				true
			)
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
final class StateRecordLogger<T> {
	
	var wrappedValue: StateRecord<T>  {
		didSet {logDiff()}
	}
	
	init(wrappedValue: StateRecord<T>) {self.wrappedValue = wrappedValue}
	
	func logDiff() {
		guard let previous = wrappedValue.previous else {
			print("Assigning -> \(wrappedValue.value)")
			return
		}

		
		// @todo: better formatting
		print("\(previous) -> \(wrappedValue.value)")
		switch(wrappedValue.previous, wrappedValue.value) {
			case let (nil, some): break
			default: break
		}
		
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