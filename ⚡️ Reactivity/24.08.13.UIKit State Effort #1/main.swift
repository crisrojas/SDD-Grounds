
@propertyWrapper
class State<Value> {
    private var observers: [(Value) -> Void] = []
    var wrappedValue: Value {
        didSet { notifyObservers() }
    }
    
    var projectedValue: State<Value> { self }
    
    init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
    
    func bind(_ observer: @escaping (Value) -> Void) {
        observers.append(observer)
        observer(wrappedValue)
    }
    
    private func notifyObservers() {
        observers.forEach { $0(wrappedValue) }
    }
}



class ViewController: UIViewController {
    
    @State var someBool = false
    @State var someState = SomeState()
    
    lazy var label1 = UILabel()
    lazy var label2 = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
    }
    
    func setupBindings() {
        
        $someBool ~ (label1, \.isHidden)
        
        (_someBool ~ \.isHidden)(label1)
    }
}

struct SomeState {
    @State var value = "hello world"
}



infix operator ~: AssignmentPrecedence
func ~ <View: UIView, Value>(state: State<Value>, tuple: (View, ReferenceWritableKeyPath<View, Value>)) {
    state.bind { newValue in
        tuple.0[keyPath: tuple.1] = newValue
    }
}

func ~ <Root: AnyObject, Value>(state: State<Value>, keyPath: ReferenceWritableKeyPath<Root, Value>) -> (Root) -> Void {
    return { root in
        state.bind { [weak root] newValue in
            root?[keyPath: keyPath] = newValue
        }
    }
}