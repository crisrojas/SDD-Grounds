
// You can name a bool (by nature) in two oposite ways, for example, in regards of visibility, you could have a bool that reads:
//
// `var isHidden: Bool {}` (which is the case of UIView)
//
// But depending on your preferences you may want to check visibility using the opposite wording:
//
// `var isVisible: Bool {}`
//
// Depending on the context, using one nomenclature over the other could be more error prone.
//
// In the case of UIViews, I find the second nomenclature to better fit the most common use case which, is controlling view visibility through state binding:


struct Model: Equatable {}

final class LoadingView: UIView {}
final class ErrorView: UIView {}
final class SomeView: UIView {
    func update(with model: Model) {}
}

enum ViewState<T: Equatable>: Equatable {
    case loading
    case success(T)
    case error(String)
}

final class SomeViewController {
    lazy var indicator  = LoadingView()
    lazy var someView = SomeView()
    lazy var errorView  = ErrorView()
    
    // You usually have a state binded to views
    // through `didSet` property observer:
    var state = ViewState<Model>.loading {
        didSet { updateUI() }
    }
    
    // And then your verbose updateUI:
    func updateUI() {
        switch state {
            case .loading:
            indicator.isHidden = false 
            someView.isHidden = true
            errorView.isHidden = true
            case .success(let data): 
            indicator.isHidden = true
            someView.isHidden = false
            errorView.isHidden = true
            someView.update(with: data)
            case .error: 
            indicator.isHidden = true
            someView.isHidden = true
            errorView.isHidden = false
        }
    }
}

// Note thats this would had been less verbose if we had used instaed the opposite nomenclature:`isVisible`
extension UIView {
    var isVisible: Bool {
        get { !isHidden }
        set { isHidden = !newValue }
    }
}

/*
 
    We would also need to extend our ViewState enum, so we basically move the
 switch logic to it.
    That may feel not so much like a gain, but the difference is that ViewState is generic and reusable so we can leverage that logic in every other `ViewController` that uses it (in the context of an app that uses network, pretty much every controller...), reducing potential errors.
    Is not the same to manually do this three times (one per state):
    
    ```swift
    indicator.isHidden = ... 
    successView.isHidden = ...
    errorView.isHidden = ...
    ```
    
    That do it only in a single place...
*/

extension ViewState {
    var isLoading: Bool { self == .loading }
    var isSuccess: Bool { data != nil }
    
    var isError: Bool {
        switch self {
            case .error: return true
            default: return false
        }
    }
    
    var data: T? {
        switch self {
            case .success(let data): return data
            default: return nil
        }
    }
}

// Usage:

final class SomeOtherCleanerViewController {
    lazy var indicator  = LoadingView()
    lazy var someView = SomeView()
    lazy var errorView  = ErrorView()

    var state = ViewState<Model>.loading {
        didSet { updateUI() }
    }
    
    // And then your verbose updateUI:
    func updateUI() {
        indicator.isVisible = state.isLoading
        someView.isVisible  = state.isSuccess
        errorView.isVisible = state.isError
        
        if state.isSuccess {
            // if you don't like force unwrap, you could just use a 
            // guard, is a matter of preference
            // here we know this will never fail as `isSuccess` 😉
            someView.update(with: state.data!)
        }
        
    }
}

// Note that this isn't a problem in SwiftUI where you can return a different view and you don't need state bindings