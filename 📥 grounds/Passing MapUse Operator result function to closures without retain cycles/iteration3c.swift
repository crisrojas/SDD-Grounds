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

enum State<T> {
	case idle, loading(T? = nil), success(T), failure(String)
}



extension State {
	
	func data() -> T? {
		if case let .success(data) = self { return data }
		return nil
	}
	
	func previousData() -> T? {
		if case let .loading(data) = self { return data }
		return nil
	}
	
	init(_ result: Result<T, Error>) {
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

extension State {
	init() {
		self = .idle
	}
}

extension State where T: Collection, T.Element: Identifiable {
	subscript(id: T.Element.ID) -> T.Element? {
		get { data()?.first { $0.id == id } }
		set(newValue) {
			guard let data = (data() ?? previousData()) else { return }
			let removedItem = data.filter { $0.id != id }
			if let newValue {
				let new = removedItem + [newValue]
				self = .success(new as! T)
			} else {
				self = .success(removedItem as! T)
			}
			
		}
	}
}

protocol Redux: AnyObject {
	associatedtype T
	var state: State<T> {get set}
	func configƒState()
}

extension Redux {

	func update(_ next: State<T>) {
		if next.isLoading() {
			state = .loading(state.data())
			return
		}
		state = next
	}
	
	func setLoading() {
		update(.loading())
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
		(setLoading + fetchTodos - self) (State.init(_:) ~> update ~> patchFirstTodo)
	}
}

extension TodoListViewController {
	func patchFirstTodo() {
		if let first = state.data()?.first {
			let patch = setLoading + patchTodo - self
			
			// 1. map respnose
			// 2. update current state with
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
final class DiffLogger<T> {
	
	var wrappedValue: T  {
		didSet {logDiff(oldValue)}
	}
	
	init(wrappedValue: T) {self.wrappedValue = wrappedValue}
	
	func logDiff(_ oldValue: T) {
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

@propertyWrapper
public struct UndoRedo<Value> {
	
	var index: Int
	var values: [Value]
	
	public init(wrappedValue: Value) {
		self.values = [wrappedValue]
		self.index = 0
	}
	
	public var wrappedValue: Value {
		get {
			values[index]
		}
		set {
			// Inserting a new value drops any existing redo stack.
			if canRedo {
				values = Array(values.prefix(through: index))
			}
			values.append(newValue)
			index += 1
		}
	}
	
	// MARK: Wrapper public API
	
	/// A Boolean value that indicates whether the receiver has any actions to undo.
	public var canUndo: Bool {
		return index > 0
	}
	
	/// A Boolean value that indicates whether the receiver has any actions to redo.
	public var canRedo: Bool {
		return index < (values.endIndex - 1)
	}
	
	/// If there are previous values it replaces the current value with the previous one and returns true, otherwise returns false.
	@discardableResult
	public mutating func undo() -> Bool {
		guard canUndo else { return false }
		index -= 1
		return true
	}
	
	/// It reverts the last `undo()` call and returns true if any, otherwise returns false.
	/// Whenever a new value is assigned to the wrapped property any existing "redo stack" is dropped.
	@discardableResult
	public mutating func redo() -> Bool {
		guard canRedo else { return false }
		index += 1
		return true
	}
	
	/// Cleans both the undo and redo history leaving only the current value.
	public mutating func cleanHistory() {
		values = [values[index]]
		index = 0
	}
	
	// TODO: A way to implement this just storing diffs?
	// It might not be particularly usefull since it will require Value to conform to some sort of
	// diffable protocol.
	// Maybe I could implement one version just for table/collection view data sources.
	
	// TODO: Add support for limited-size history; e.g. 50
	
	// TODO: Potential alternative version supporting foundation undomanager https://developer.apple.com/documentation/foundation/undomanager
}