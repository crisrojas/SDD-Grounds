//
//@propertyWrapper
//class State<Value> {
//
//  private var observers: [(Value) -> Void] = []
//  
//  var wrappedValue: Value {
//      didSet { notifyObservers() }
//  }
//  
//  var projectedValue: Binding<Value> {
//      Binding(get: { self.wrappedValue },
//              set: { self.wrappedValue = $0 })
//  }
//  
//  init(wrappedValue: Value) {
//      self.wrappedValue = wrappedValue
//  }
//  
//  func bind(_ observer: @escaping (Value) -> Void) {
//      observers.append(observer)
//      observer(wrappedValue)
//  }
//  
//  private func notifyObservers() {
//      observers.forEach { $0(wrappedValue) }
//  }
//}
//
//struct Binding<Value> {
//  let get: () -> Value
//  let set: (Value) -> Void
//}
//
//protocol StateBindable {
//  associatedtype Value
//  var stateBinding: Binding<Value> { get set }
//}
//
//extension UILabel: StateBindable {
//  typealias Value = String?
//  
//  var stateBinding: Binding<String?> {
//      get {
//          Binding(
//              get: { self.text },
//              set: { self.text = $0 }
//          )
//      }
//      set {
//          text = newValue.get()
//          newValue.set(text)
//      }
//  }
//}
//
//infix operator ~: AssignmentPrecedence
//func ~ <T: StateBindable>(left: inout T, right: Binding<T.Value>) {
//  left.stateBinding = right
//}
//
//class ViewController: UIViewController {
//  @State var someState = SomeState()
//  @State var otherState = "hello"
//
//  lazy var label1 = UILabel()
//  lazy var label2 = UILabel()
//
//  override func viewDidLoad() {
//      super.viewDidLoad()
//      setupBindings()
//  }
//
//  func setupBindings() {
//      //label1 ~ $someState.map(\.value)
//      label2 ~ $otherState
//  }
//}
//
//struct SomeState {
//  var value = "hello world"
//}
//
//extension Binding {
//  func map<T>(_ keyPath: KeyPath<Value, T>) -> Binding<T> {
//      Binding<T>(
//          get: { self.get()[keyPath: keyPath] },
//          set: { newValue in
//              var current = self.get()
//              //current[keyPath: keyPath] = newValue
//              self.set(current)
//          }
//      )
//  }
//}