import Foundation

/*
https://swift2931.github.io/cleanarchitecturesucks/posts/2017-12-05_Swift-4ce-3976f3835c1e.html
Jim Lai advocates for a simplification of redux.
A redux without a global store and reducer functions.

So basically, this is a way of doing MVC inspired by redux.
*/

// MARK: - Estado
enum LoginState {
    case initial
    case loading
    case loggedIn(username: String)
    case error(message: String)
}

// MARK: - Acciones
// We still model the possible actions of a given viewController with enum
enum LoginAction {
    case startLogin(username: String, password: String)
    case loginSuccess(username: String)
    case loginFailure(error: Error)
}

class LoginViewController: UIViewController {
    
    // MARK: - UI Elements
    private let usernameTextField = UITextField()
    private let passwordTextField = UITextField()
    private let loginButton = UIButton()
    private let statusLabel = UILabel()
    
    // MARK: - State
    // Property observer ensures view is a function of state
    private var state: LoginState = .initial {
        didSet { updateUI() }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateUI()
    }
    
    // MARK: - UI Setup
    // Configure UI elements (omitted for brevity)
    private func setupUI() {}
    
    // MARK: - State Management
    private func updateUI() {
        switch state {
        case .initial:
            statusLabel.text = "Please log in"
            loginButton.isEnabled = true
        case .loading:
            statusLabel.text = "Logging in..."
            loginButton.isEnabled = false
        case .loggedIn(let username):
            statusLabel.text = "Welcome, \(username)!"
            loginButton.isEnabled = false
        case .error(let message):
            statusLabel.text = "Error: \(message)"
            loginButton.isEnabled = true
        }
    }
    
    // MARK: - Actions
    @objc private func loginButtonTapped() {
        guard let username = usernameTextField.text, let password = passwordTextField.text else {
            return
        }
        
        dispatch(.startLogin(username: username, password: password))
    }
    
    // We have a dispatch function that handles the actions without an explicit reducer
    // Though, nothing holds you against having and injecting a custom reducer (but I do think that would be overengineering)
    private func dispatch(_ action: LoginAction) {
        switch action {
        case .startLogin(let username, let password):
            state = .loading
            
            // Simulate network call
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                if username == "demo" && password == "password" {
                    self.dispatch(.loginSuccess(username: username))
                } else {
                    self.dispatch(.loginFailure(error: NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Invalid credentials"])))
                }
            }
        case .loginSuccess(let username):
            state = .loggedIn(username: username)
        case .loginFailure(let error):
            state = .error(message: error.localizedDescription)
        }
    }
}