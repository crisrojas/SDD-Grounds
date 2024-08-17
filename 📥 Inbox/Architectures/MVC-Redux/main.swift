import Foundation

// Links:
// - https://swift2931.github.io/cleanarchitecturesucks/posts/2017-12-05_Swift-4ce-3976f3835c1e.html

// Jim Lai advocates for a simplification of redux applied to the MVC design pattern: 
// A redux without a global store and reducer functions.
// Basically a redux-flavored MVC that models actions and local state with enums.


// We model the local state with an enum:
enum LoginState {
    case initial
    case loading
    case loggedIn(username: String)
    case error(message: String)
}

// As in redux, we still model the possible actions of a given viewController with enum:
enum LoginAction {
    case startLogin(email: String, pass: String)
    case recoverPass
}

// Redux contract to be adopted by ViewControllers
protocol Redux: AnyObject {
    // Each redux object has a state:
    associatedtype State
    var state: State {get set}
    
    /// Each redux object is responsible for implementing a function that
    /// ensures view is a function of stte
    func functionOfState()
    
    /// Each redux object has a function used to updateUI.
    /// This function dispatches by default on the main queue.
    func updateUI()
    
    associatedtype Action
    /// Each redux object implements an action dispatcher
    func dispatch(_ action: Action)
}

// Default implementations
extension Redux {
    func updateUI() { dispatch(functionOfState, on: .main) }
    func dispatch(_ action: @escaping () -> Void, on queue: DispatchQueue) {
        queue.async { action() }
    }
    
    // Useful for chaining functions after mapping an async result.
    // Ex.) fetch(completion: mapResultToState ~> update)
    func update(_ newState: State) {
        state = newState
    }
}

final class LoginViewController: UIViewController {
    
    private let emailField = UITextField()
    private let passField  = UITextField()
    private let loginButton = UIButton()
    private let statusLabel = UILabel()
    
    var state = LoginState() {
        // Property observer ensures view is kept in sync with state
        didSet { updateUI() }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    func functionOfState() {
        statusLabel.text = state.statusLabel
        loginButton.isEnabled = state.isInitial && emailField.text != nil
    }
    
    @objc private func loginButtonTapped() {
        guard validate(email: email!) else {
            state = .error(message: "Wrong email")
            return
        }
        
        guard validate(password: pass!) else {
            state = .error(message: "Wrong password")
            return
        }
        
        dispatch(.startLogin(email: email!, pass: pass!))
    }
    
    private let map = LoginState.init(_:)
    
    /// Handles actions. 
    /// In most scenearios we won't need an explicit reducer
    func dispatch(_ action: LoginAction) {
        switch action {
        case .startLogin(let email, let pass):
            state = .loading
            login(
                email: email,
                pass: pass, 
                onDone: map ~> update
            )
            
        case .recoverPass: break
        }
    }
    
}

// MARK: - Controller helpers
extension LoginViewController {
    var email: String? { emailField.text }
    var pass: String? { passField.text }
    
    func loginIsEnabled() -> Bool {
        state.isInitial && emailField.text != nil && passField.text != nil
    }
}

// MARK: Mixing injection
extension LoginViewController: Redux {}
extension LoginViewController: LoginService {}
extension LoginViewController: AuthValidator {}