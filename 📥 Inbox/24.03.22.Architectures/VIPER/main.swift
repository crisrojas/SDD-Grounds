protocol Wireframe: AnyObject {}
protocol ViewInterface: AnyObject {}

class Repository {
	static let shared = Repository()
}

class Presenter {
	private weak var view: ViewInterface!
	private weak var wireframe: Wireframe!
	private weak var repository: Repository! // Does it really need to be weak?
	
	init(view: ViewInterface, wireframe: Wireframe, repository: Repository = .shared) {
		self.view = view
		self.wireframe = wireframe
		self.repository = repository
	}
}

class ViewController: UIViewController {
	var eventHandler: Presenter?
}

extension ViewController: Wireframe {}
extension ViewController: ViewInterface {}

class Configurator {
	static func prepareScene(for viewController: UIViewController) {
		let vc = viewController as! ViewController
		let presenter = Presenter(
			view: vc, 
			wireframe: vc
		)
		
		vc.eventHandler = presenter
	}
}