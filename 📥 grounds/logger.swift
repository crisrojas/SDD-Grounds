

@propertyWrapper
final class State<T> {
	
	var wrappedValue: T  {
		didSet { 
			logDiff(oldValue)
			next?(wrappedValue)
		}
	}
	
	var next: ((T)->Void)?
	var projectedValue: State<T> { self }
	
	func onChange(_ block: @escaping (T) -> Void) {
		next = block
	}
	
	init(wrappedValue: T) {self.wrappedValue = wrappedValue}
		
	func logDiff<A>(_ old: A?) {
		guard let old else { return }
		let previous = Mirror(reflecting: old)
		let current  = Mirror(reflecting: wrappedValue)
		guard !current.children.isEmpty else {
			print("\(old) <- \(wrappedValue)")
			return
		}
		for (prev, current) in zip(previous.children, current.children) {
			if "\(prev.value)" != "\(current.value)" {
				print("\(prev.label ?? "") <- \(current.value), previous: \(prev.value)")
			}
		}
	}
}  

struct Person {
	var firstName: String
	var lastName: String
}


enum ViewState {
	case idle, loading, success, error
}

final class View {
	
	func update(_ model: Person) {}
}

final class Controller {
	@State var someState = "hello world"
	@State var person = Person(firstName: "Cristian", lastName: "P. Rojas")
	@State var state = ViewState.idle
	lazy var view = View()
	
	func viewDidLoad() {
		// @todo: should weakify
		$person.onChange(view.update)
	}
	
	func updateUI() {
		print("Ui should be updated")
	}
}

var c = Controller()
c.viewDidLoad()
c.someState = "new state"
c.person.firstName = "Cristian Felipe"
c.state = .loading
c.state = .success

