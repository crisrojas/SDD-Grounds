//
//  MVVM.swift
//  PlaygroundsTests
//
//  Created by Cristian Patiño Rojas on 21/11/23.
//
import SwiftUI

struct User: Identifiable, Codable {
    let id: UUID
    let firstName: String
}

extension Data {
    static var anyData: Data {Data()}
}
/// In MVVM pattern, the state of the view (values it needs to be rendered) is provided by an external object.
///
/// We can distinguish basically three types of state that a view can hold.
///
/// - Collection of a given entitiy from which it builds a list
/// - An entity (or primitive types) from which it builds.
///
/// When you fetch data from newtork/database, you usually get first a collection, which let you build detail views.
/// So lets start there:
///
/// Lets say we got a view that displays a list of users.
/// In MVVM you'll have something like this:
///

fileprivate struct ExampleView: View {
    @State var vm = ExampleViewViewModel()
    var body: some View {
        List(vm.users) { item in
            Text(item.firstName)
        }
    }
}

/// Where viewModel will be something like this:
///
/*@Observable */final class ExampleViewViewModel {
    var users = [User]()
    let httpClient: HTTPClientProtocol
    
    init(httpClient: HTTPClientProtocol = HTTPClient.shared) {
        self.httpClient = httpClient
    }
    
    func getData() async throws {
        users = try await httpClient.get()
    }
}

/// ViewModel has a dependency on a HTTPClientProtocol
///
protocol HTTPClientProtocol {
    func get<C: Codable>() async throws -> C
}

/// Which concrete implementation will hit the network.
/// Nowadays having probably a dependency on URLSession.
///
fileprivate final class HTTPClient: HTTPClientProtocol {
    static let shared = HTTPClient()
    let jsonDecoder = JSONDecoder()
    func get<C: Codable>() async throws -> C {
        // some call to newtork
        try jsonDecoder.decode(C.self, from: Data.anyData)
    }
}

/// ViewModel was meant to:
///
/// Decrease the burden of business logic on the controllers.
/// Achieve a higher level of decoupling and improve reusability. // @todo: verify
///
/// But observe that view now has a dependency on ViewModel, which has a dependency on HttpClientProtocol, which
/// implicitly hints the view state is going to be buid from network.
///
/// So we have implicitly coupled our view to a network call.
/// So, the view knows where its data comes from.
///
/// ¿How is that more docupled than just do data retrieving in the view struct / ViewController ? `test`

struct ExampleView_3: View {
    @State var users = [User]()
    @State var isLoading = false
    let httpClient: HTTPClientProtocol
    var body: some View {
        List(users) { item in
            Text(item.firstName)
        }
        .task {
            users = (try? await httpClient.get()) ?? []
        }
    }
}

/// If you only need the httpClient for dataretrieving, you could even go a step further:

struct ExampleView_4: View {
    @State var users = [User]()
    let load: (() async throws -> [User])?
    var body: some View {
        List(users) { item in
            Text(item.firstName)
        }
        .task {
            users = (try? await load?()) ?? []
        }
    }
}

/// The view becamese really data agnostic.
/// Usage:

let loadUsers_network: () async throws -> [User] = {[]}
var exv4 = ExampleView_4(load: loadUsers_network)

let loadUsers_coredata: () async throws -> [User] = {[]}
let exv4_b = ExampleView_4(load: loadUsers_coredata)



/// Lets say wou want to reuse that view with a database call. How would you do that?
///
/// You will need to create a type that conforms to HttpClient but fetches from database (awkward...)
/// Then inject it into the viewModel
/// Then inject the viewModel into the view.
///
///
/// The view implicitly now that its data is going to be fetched from a network call.
/// ¿How is that decoupling? ¿How is the view reusable?
///
/// if we want a view that is decoupled from its datasource & reusable with any kind of datasource it should be:
/// ...wel, data source agnostic (duuuh)
///
/// The datasource should be provided to the view from its owner, and the owner of the view in UIKit is the ViewController.
///
/// ViewController is NOT the View, but its controller, is right there, in the name.
///
/// So If view should be agnostic and controller owns and control the view. The data flows as follow:
/// Model -> Controller -> View
///
/// MVVM treats the ViewController as a View (there are cases were you want to treat the VC as a View but only to levarage its life cycle options)
/// So MVVM basically becames a redundant controller of the controller. So the data flow basically becomes like this:
///
/// Model -> ViewModel -> Controller (that holds view)
///
/// If that redundancy ins't clear, lets see an example.
/// This is how we use to implement the pattern in one of the places I worked.
///
/// To make things more concrete, lets say we want to load  a list of profiles in a screen.
///
/// Note that the pattern has many interpretations, this is the one we use to do when I first learned iOS dev:
///
///
/// Lets define the entity that will drive the UI:
struct Profile {
    let id: UUID ; let firstName: String
}

/// The binding with the view is usually made through delegate pattern.
protocol ProfilesViewInterface: AnyObject {
    func updateUI(_ model: [User])
}

/// So lets conform the view to the protocol
extension ProfilesViewController: ProfilesViewInterface {
    func updateUI(_ model: [User]) {
        // Do something
    }
}

/// The Controller owns the viewModel and configures itself as a delegate.
/// Note that in other implementations like VIPER, the Presenter, which is equivalent to the ViewModel, is
/// injected into the view
fileprivate final class ProfilesViewController {
    // ... owned view/views ...
    // ... other deps ...
    // @todo: read about this setting from other people
    lazy var vm: ProfilesViewModel = {
        let vm = ProfilesViewModel()
        vm.view = self
        return vm
    }()
}

/// Then in you view model you will own a weak dependency on the view protocol
fileprivate final class ProfilesViewModel {
    weak var view: ProfilesViewInterface?
    
    func getProfiles() {
        // ... some async fetch ...
        let fetchedData = [User]()
        view?.updateUI(fetchedData)
    }
}

/// And then you'll load the profiles through the viewModel in response to an event, usually viewWillAppear:
extension ProfilesViewController {
    func viewWillAppear() {
    // super.viewWillAppear()
        vm.getProfiles()
    }
}

/// Lets take a look at how this may look using the MVC..
///
fileprivate final class ProfilesViewController_1: UIViewController {
    
    /// 1. Set model & binding
    /// 1.1 Set a variable that holds the state use for UI rendering
    var model = [Profile]() {
        /// 1.2. Set up an automatic binding through property observers
        didSet { updateUI() }
    }
    
    /// 2. Fetch and update
    override func viewDidLoad() {
        
        /// 1. Fetch data from somewhere
        let fetchedModel = [Profile]()
        
        /// 2. Update model
        model = fetchedModel
    }
    
    /// 3. Update the UI
    func updateUI() {}
}

/// Note how simple yet powerful this approach is.
///
/// One may think this will work only in small projects and for scalability you may want to use MVVM and derived (VIPER, etc...)
///
/// There are two things about this:
///
/// 1. From which size you start considering the project big enough to start thinking about using this?
/// 2. Provide proof that such approach will not scale
/// 3. Provide proof that MVVM wil scale
///
/// Also, what do you mean a "more complex" app? An app that has more entities, more screens? So you want to create up to 7 files per crud intent?
/// Why is/was the defacto Standard? I've worked in X projects within my career path.
/// All of them used this kind of pattern or even more complicated variations.
///
/// With the perspective that time gives I can confidently say none of them needed this pattern.
/// So the next question one may asked is, from which size should you consider using this pattern.
/// Here's my opinonated answer: from no one. You should'nt use MVVM.
///
/// As I said before, MVVM is just an extra layer over MVC that acts as a controller because no reason.
///
/// Not to say its a boilerplated pattern.
/// On some variations you need a ton of boilerplate for each scene of your app.
///
/// Having 7 files per scene won't scale.
/// If you know how human working memory works, you know this is shooting you in the foot.
/// Trust me. I failed my biology's bachelor.
///
/// If you want reusability you can move the view owned by the controller to its own class.
/// And inject it into the viewController
fileprivate final class ProfileView: UIView {
    func configure(with: [Profile]) { /* Configure your view */ }
}

fileprivate final class ProfilesViewController_2: UIViewController {
    
    lazy var root = ProfileView()
    var model = [Profile]() {
        didSet {root.configure(with: model)}
    }
  
    override func loadView() {
    
        /// Note that this is a valid dependency injection method
        /// officially used by sdk.
        ///
        /// You don't need overengineered constructors. We'll dive on DI in other article/playground.
        view = root
    }
}

/// You usually want some dependencies on your ViewModel, usually you would want a
///
///
///
struct ExampleView_2: View {
    
    @State var model: Data?
    var load: (() async throws -> Data)? = nil
    
    var body: some View {
        Text(model == nil ? "Loading" : "Loaded")
            .task {
                model = try? await load?()
            }
    }
}

// MARK: - Dependencies
fileprivate final class TableView {}
fileprivate class UIView {}
fileprivate class UIViewController {
    var view = UIView()
    func viewDidLoad() {}
    func viewWillAppear() {}
    func loadView() {}
}

// MARK:  - Tests
fileprivate func testBis() {
    var view = ExampleView_2()
    func load() async throws -> Data {.init()}
    view.load = load
    
}


