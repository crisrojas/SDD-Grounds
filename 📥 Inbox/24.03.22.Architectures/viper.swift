protocol SomeInteractorProtocol {
	func callAsFunction()
}

final class SomeInteractor: SomeInteractorProtocol {
	func callAsFunction() {}
}


// 1 Single responsability -> HANDLE THE ENTITY PERSISTENCE
final class Crud<Entity> {
	func create(_ item: Entity) async throws {}
	func read() async throws -> [Entity] {[]}
	func update(_ item: Entity) async throws  {}
	func delete(_ item: Entity) async throws {}
}


struct Todo {}
// M
// VC -> V
// VM -> ACTIONS -> C 
// MVVM === MVC WITH EXTRA STEPS. SPOILERT: AREN'T WORTH THE TROUBLE.
// VIPER == SAME
// MVVM ....VIPER, etc... -> MVC SCALES REALLY WELL AND YOU DON'T NEED TO END UP WITH MASSIVE CONTROLLERS. 
typealias TodoUpdater = (_ item: Todo) async throws -> Void
// DI -> something else ....the industry accepts...
// This clean architecture -> Scale ;...

// Ignores -> Simplicity, and how human brain works (aka working memory)

let todoCrud = Crud<Todo>()

final class Repository {}
// worst ergonmoics
// add a dependency to your project
// setup the container ...
final class Container {
	
	static let repository = Repository()
}

// protocol
// conformance
// fake object that conforms to that protocol..

final class SomePresenter {
	var todoUpdater: TodoUpdater?
	
	func udpate(_ item: Todo) async throws {
		try await todoUpdater?(item)
	}
}


final class SomePresenter_2 {
	
	// Solid CULT -> 
	// a class should have a single responsability.
	// 
	// what is a responsability? -> 
	// what define what a single responsability is??
	// 
	// Persitence -> User
	// Create <- 
	// Read <- 
	// Update <- 
	// Delete it.<-
	
	// Create is a responsability
	// Read is a responsability
	// Update is a responsability
	// Delete is a responsability
	
	// ....
	var someInteractor: SomeInteractorProtocol = SomeInteractor()
	let crud = Crud<Todo>()
	

	func update(_ item: Todo) async throws {
		try await crud.update(item)
	}
	
	func singleReponsability() { 
		someInteractor()
	}
}

let first = SomePresenter()

let second = SomePresenter_2()
second.someInteractor = SomeInteractor()