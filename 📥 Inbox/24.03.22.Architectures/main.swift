
final class Service {
	func fetchData(completion: (Result<String, Error>) -> Void) {
		completion(.success("success!"))
	}
}

protocol View: AnyObject {
	func updateView(msg: String)
}


final class Presenter {
	weak var view: View?
	let service: Service
	
	init(service: Service) {
		self.service = service
	}
	
	func fetchData() { 
		service.fetchData(completion: updateUI)
	}
	
	func updateUI(with result: Result<String, Error>) { 
		switch result {
			case .success(let msg):
				view?.updateView(msg: msg)
			case .failure(let error):
				view?.updateView(msg: "\(error)")
		}
	}
}


final class ViewController {
	
	// Views
	lazy var label = Label()
	
	// Presenter
	var eventHandler: Presenter?
	     
	func fetchData() {
		eventHandler?.fetchData()
	}
}

extension ViewController: View {
	func updateView(msg: String) {
		label.text = msg
	}
}