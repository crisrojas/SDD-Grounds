// In MVVM you treat your VC as a View and move almost everything else to a new class called ViewModel

// Your viewModel usually holds the same responsability than a controller, so, basically, you still got a MVC but with extra steps:

final class ErrorView: UIView {}

final class ViewController: UIViewController {
		
	lazy var label     = Label()
	lazy var indicator = Indicator()
	lazy var errorView = ErrorView()
	
	var viewModel = ViewModel()
	
	func updateUI() {
//		label.isVisible = state.isSuccess
//		indicator.isVisible = state.isLoading
//		errorView.isVisible = state.isError
//		label.text = state.data
	}
	
	override func viewDidLoad() {
	}
}

final class ViewModel {
	var state = State<String>.idle {
		didSet {updateUI()}
	}
	
	let service = Service()

	// @todo: how to do binding?
	func updateUI() {}
	
	func fetch() { 
		service.fetch { [weak self] in
			self?.state = .init(from: $0)
		}
	}
}

import Foundation

class Service {
	var session: URLSession { URLSession.shared }
	func fetch(completion: @escaping (Result<String, Error>) -> Void) {
		completion(.success("success!"))
	}
}



