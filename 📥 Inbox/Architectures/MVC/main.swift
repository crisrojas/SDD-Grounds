final class ErrorView: UIView {}

// View is (optional) declared outside viewController so we have shorter ViewControllers
// though isn't necessary as we'll use POP to inject dependencies so we won't end with big VC's anyways 
final class View: UIView {
    
    var state = State<String>.idle {
        // View is a function of state, achieved through property observer
        didSet {updateUI()}
    }
    
    lazy var label     = Label()
    lazy var indicator = Indicator()
    lazy var errorView = ErrorView()
    
    // View is a function of state
    func updateUI() {
        // State has computed vars so we can avoid switch and code is more concise
        label.isVisible = state.isSuccess
        indicator.isVisible = state.isLoading
        errorView.isVisible = state.isError
        label.text = state.data
    }
}


// Networking is abstracted (refactored) so we can reuse fetch
import Foundation
protocol Service {}

// We refactor fetch and give default implementation
extension Service {
    var session: URLSession { URLSession.shared }
    func fetch(completion: @escaping (Result<String, Error>) -> Void) {
        completion(.success("success!"))
    }
}

// Dependency injection through protocol conformance 
// (used as a plug-and-play/mixin that provides functionality to a class through default implementation)
final class ViewController: UIViewController, Service {
    lazy var rootView = View()
    
    // View is injected (optionnaly)
    override func loadView() { 
        view = rootView
    }
        
    override func viewDidLoad() {
        // @todo: Find a way of return unwrapped self on closure. See Jim Lai's implementation
        fetch { [weak self] in
            self?.rootView.state = .init(from: $0)
        }
    }
}



