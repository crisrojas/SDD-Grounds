import Foundation

/*
@todo: 
1. Hacer que el deinit no se llama
2. Averiguar porque el print no se está llamando (en asyncAfter) ...
*/
class API {
	func fetch(_ completion: @escaping () -> Void) {
		print("Fetching...")
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
			print("Fetch completed, notifying upwards...")
			completion()
		}
	}
}


class BaseController {
    var api = API()
	func didFetch() {print("Fetch done")}
	
	func didLoad() {
		api.fetch { [weak self] in
			self?.didFetch()
		}
	}
	
	deinit { print("Deinit basecontroller") }
}

class Controller {
    var api = API()
	func didFetch() {print("Fetch done")}
	
	func didLoad() {
		api.fetch { [unowned self] in
			self.didFetch()
		}
	}
	
	deinit { print("Deinit controller") }
}

var controller: Controller? = Controller()
controller?.didLoad()
sleep(5)
//controller = nil