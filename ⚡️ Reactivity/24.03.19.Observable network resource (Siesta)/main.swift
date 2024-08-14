// 24.03.19
// #reactivity #uikit #networking #architecture

// The goal of this mini playground is to better understand the principles
// behind [Siesta](https://github.com/bustoutsolutions/siesta).

// Note that even though this pattern comes from a networking lib,
// This could be use to implemnent observable persistence on UIKit
// with solutions that, contrary to CoreData, don't support it out of the box (SQLite, Codable to filedisk, etc...)

// MARK: - Resource state
// A remote resource has an state that determines wether it has been
// fetched before:
enum ResourceState<T> {
    case idle
    case loading
    case success(T)
    case error(String? = nil)
    
    
    var isIdle: Bool {
        if case .idle = self {return true}
        return false
    }
    
    var isLoading: Bool {
        if case .loading = self {return true}
        return false
    }
    
    var isSuccess: Bool {
        if case .success = self {return true}
        return false
    }
    
    var isError: Bool {
        if case .idle = self {return true}
        return false
    }
    
    var data: T? {
        if case let .success(data) = self { return data }
        return nil
    }
    
    mutating func update(from result: Result<T, Error>) {
        self = .init(from: result)
    }
    
    init(from result: Result<T, Error>) {
        switch result {
            case .success(let t): self = .success(t)
            case .failure(let error): self = .error(error.localizedDescription)
        }
    }
}

// MARK: - Resource implementation
// We have a generic deserialization object
enum JSON {case empty}

// A resource represents a collection of entities from the data api:
final class Resource {
    
    // A resource could use a Codable object instead of JSON:
    // `final class Resource<T: Codable> { ...  }`
    // `state: ViewState<T>`
    // But for the sake of simplicity, lets stick with our JSON entity.
    var state: ResourceState<JSON> = .idle {
        didSet { callbacks.forEach { $0(state) } }
    }
    
    var callbacks = [(ResourceState<JSON>)->Void]()
    let path: String
    init(_ p: String) { path = p }
    
    // A resource knows how to retrieve, create, modify and delete itself
    // Thus it has a method for each HTTP verb
    func fetch() {
        state = .loading
        
        // Here you would use URLSession to retrieve the data 
        // using the resource url...
        // `let url = baseURL.appendingPathComponent(path)`
        state.update(from: .success(.empty))
    }
    

    func post()   {/* Use URLSession*/}
    func patch()  {/* Use URLSession*/}
    func delete() {/* Use URLSession*/}
    
    // API for observing resource changes
    func onChange(_ completion: @escaping (ResourceState<JSON>)->Void) { 
        callbacks.append(completion)
    }
}

// We have our resources declared as globals
// so everyone can observe them:
final class API {
    private init() 
    static var profiles = Resource("/profiles")
}

// MARK: - UI usage
class View {
    var isHidden = false
}

extension View {
    var isVisible: Bool { 
        get { !isHidden }
        set { isHidden = !newValue }
    }
}

final class ProfilesView: View {
    func update(with json: JSON?) {
        guard let json else { return }
        // do something with the json
    }
}

final class ErrorView: View {}
final class ActivityIndicator: View {}


final class ProfilesViewController {
    
    // Views
    lazy var profilesView = ProfilesView()
    lazy var indicator   = ActivityIndicator()
    lazy var errorView   = ErrorView()
    
    // States
    var resource = Resource.profiles
    
    func setInitialStates() {
        profilesView.isHidden = true
        indicator.isHidden    = true
        errorView.isHidden    = true
    }
    
    func startObservingResource() {
        resource.onChange(updateUI)
    }
    
    func updateUI(state: ResourceState<JSON>) { 
        indicator.isVisible    = state.isLoading
        profilesView.isVisible = state.isSuccess
        errorView.isVisible    = state.isError
        profilesView.update(with: state.data)
    }
    
    func fetchProfiles() {
        resource.fetch()
    }
}


final class AnotherViewController {
    var resource = Resource.profiles
    
    var label = UILabel()
    
    func setInitialStates() {
        label.text = "No resource found"
    }
    
    func updateUI(state: ResourceState<JSON>) {
        if state.isSuccess {
            label.text = "Resource has been fetched!"
        }
    }
}

protocol ResourceObserver {
    var resource: Resource { get set }
    func updateUI(state: ResourceState<JSON>)
    func setInitialStates()
}

extension ResourceObserver {
    func startObservingResource() {
        resource.onChange(updateUI)
    }
}

extension ProfilesViewController: ResourceObserver {}
extension AnotherViewController: ResourceObserver {}

describe("Test resource observation works") {
    given("a resource shared among two viewControllers") {
        
        var resource = Resource("/profiles")
        var profilesVC = ProfilesViewController()
        var anotherVC = AnotherViewController()
        profilesVC.resource = resource
        anotherVC.resource = resource
        
        when("both start monitoring resource") {
            profilesVC.startObservingResource()
            anotherVC.startObservingResource()
            
            and("they have default initial states") {
                
                anotherVC.setInitialStates()
                profilesVC.setInitialStates()
                
                expect(profilesVC.profilesView.isHidden).toBe(true)
                expect(anotherVC.label.text).toBe(equalTo("No resource found"))
                
                when("one of them fetches the resource") {
                    profilesVC.fetchProfiles()
                    
                    then("both view controllers states are updated") {
                        expect(profilesVC.indicator.isHidden).toBe(true)
                        expect(profilesVC.profilesView.isHidden).toBe(false)
                        expect(anotherVC.label.text).toBe(equalTo("Resource has been fetched!"))
                    }
                }
            }
        }
    }
}


