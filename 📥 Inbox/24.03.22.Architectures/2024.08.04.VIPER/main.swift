protocol View: AnyObject {
	func setLoading()
	func setError(_ message: String)
	func setSuccess(_ data: String)
}

protocol Wireframe: AnyObject {}

final class ViewControllerConfigurator {
	
	static func prepareViewController(_ viewController: UIViewController) {
		let vc = viewController as! ViewController
		let presenter = Presenter(view: vc, wireframe: vc)
		vc.eventHandler = presenter
	}
}

enum LifeCycleEvent {
	case didLoad 
}

final class Presenter {
	weak var view: View!
	weak var wireframe: Wireframe!
	let service: Service
	
	var state = State<String>.idle {
		didSet {updateUI()}
	}
	
	func setupView(for lifeCycleEvent: LifeCycleEvent) {
		switch lifeCycleEvent {
			case .didLoad: view?.setLoading()
		}
	}
	
	func updateUI() {
		switch state {
			case .idle, .loading: view?.setLoading()
			case .success(let data): view?.setSuccess(data)
			case .error(let msg): view?.setError(msg)
		}
	}
	
	func fetch() { 
		service.fetch { [weak self] in
			self?.state = .init(from: $0)
		}
	}
	
	
	init(view: View, wireframe: Wireframe, service: Service = .shared) {
		self.view = view
		self.wireframe = wireframe
		self.service = service
	}
}


final class ErrorView: UIView {}

final class ViewController: UIViewController {
		
	lazy var label     = Label()
	lazy var indicator = Indicator()
	lazy var errorView = ErrorView()
	
	var eventHandler: Presenter?
	
	func setupUI() {
		label.isHidden = true
		indicator.isHidden = false
		errorView.isHidden = true
	}
	
	override func viewDidLoad() {
		eventHandler?.setupView(for: .didLoad)
	}
}

extension ViewController: View {
	func setLoading() {}
	
	func setError(_ message: String) {
		
	}
	
	func setSuccess(_ data: String) {
		
	}
}
extension ViewController: Wireframe {}


import Foundation

class Service {
	let session: URLSession
	static let shared = Service()
	
	init(session: URLSession = .shared) {
		self.session = session
	}
	
	func fetch(completion: @escaping (Result<String, Error>) -> Void) {
		completion(.success("success!"))
	}
}



