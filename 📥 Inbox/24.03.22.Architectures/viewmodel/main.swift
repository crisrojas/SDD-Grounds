import Foundation

// https://www.youtube.com/watch?v=RbPLXjRkjZo
/*

MVVM Pattern is nothing more than a cumbersome MVC.

You treat the controller as a View, and the ViewModel as a Controller (you're basically refactoring out “Control” from ViewController...)

So many questions arise when thinking about its advantages over MVC:

- If it is a controller, why call it a ViewModel?
- If you're just moving the logic from ViewController to ViewModel (a.k.a, another contrller), why bother at all?

Advocates of MVVM and similar (MV-something, like VIPER, etc...), usually talk about improving testability.
*/

// Yet this:
final class LoginViewController: UIViewController {
	
	var state = State<User>.initial {
		didSet { updateUI() }
	}
	
	var webservice: WebService!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		updateUI()
	}
	
	func updateUI() {}
	
	func login() {
		state = .loading
		webservice.login { [weak self] result in 
			guard let self else { return }
			state = .init(result: result)
		}
	}
}

// Is not less testable than this
final class LoginViewModel {
	
	var state = State<User>.initial	
	var webservice: WebService!
	
	func login() {
		state = .loading
		webservice.login { [weak self] result in 
			guard let self else { return }
			state = .init(result: result)
		}
	}
}

final class LoginView: UIViewController {
	
	let controller = LoginController()
	
	private let loginButton = UIButton()
	private let statusLabel = UILabel()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		controller.notifyObserver = updateUI
		controller.fetch()
	}
	
	func updateUI() {
		 switch controller.state {
			case .initial:
			statusLabel.text = "Please log in"
			loginButton.isEnabled = true
		case .loading:
			statusLabel.text = "Loading"
			loginButton.isEnabled = false
		case .success(let user):
			statusLabel.text = "User logged: \(user.name)"
		case .error(let error):
			statusLabel.text = "Error: \(error)"
		}
	}
}


final class LoginController: Fetcher {
	var state = State<User>.initial {
		didSet { notifyObserver() } 
	}
	
	var notifyObserver = {}
	
	func fetch() {
		state = .loading
		fetch(url: Api.user!) { [weak self] result in 
			guard let self else { return }
			self.state = .init(result: result)
		}
	}
}