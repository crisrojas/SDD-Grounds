//
//  Modularity and composiition ii.swift
//  Effin
//
//  Created by Cristian Felipe Patiño Rojas on 03/12/2023.
//

import Foundation

/*
Lets say we want to modularize our app.

There are many ways of doing this, mainly:
- Having a monolitic app split in low-level modules
- Feature-based modularization (1 feature == 1 app)

In this mini-playground I will explore the first.

We'll create a module for most common parts of an app:

- Network
- Persistence
- UI

The idea is to have each of those modules as a xcframework
(could be a Swift Packge too) and we'll import them from the main module that will assembly the app.
*/

/* 
Each module has its own entities.

The UI expects its own Feed entity, this would be equivalent to a ViewModel, but we'll ommit that nomenclature and call it simply `Feed` instead of `FeedViewModel` as it is namespaced to its enclosing module, so that would be redundant and verbose.

The Database and Network will have their own Feed to, used to deserialized the data, those would be equivalent to a DTO, again will ommit the verbose nomenclature (FeedPersistenceObject, ApiFeed, or whatever prefix-suffix naming convention...) as its unecessary.
*/
extension Network  {struct Feed: Identifiable {let id: UUID}}
extension Database {struct Feed: Identifiable {let id: UUID}}
extension UI       {struct Feed: Identifiable {let id: UUID}}
extension Main     {struct Feed: Identifiable {let id: UUID}}

extension Network  {typealias Feeds = [Feed]}
extension Database {typealias Feeds = [Feed]}
extension UI       {typealias Feeds = [Feed]}
extension Main     {typealias Feeds = [Feed]}

// MARK: - Common utilities
typealias VoidAction <T> = (T) -> Void
typealias VoidClosure<T> = (@escaping VoidAction<T>) -> Void

// MARK: - UI
enum UI {
    enum ViewState<T> {
        case idle
        case loading
        case success(T)
        case error(Error)
    }
    
    
    // In our UI model we got a view that loads
    // content asynchronously. 
    // For reusability, it accepts the load function.
    // It could be a delegate if more methods are needed.
    final class FeedView {
        let loader: VoidClosure<Feeds>
        
        private var state = ViewState<Feeds>.idle {
            didSet{updateUI()}
        }
        
        init(loader: @escaping VoidClosure<Feeds>) {self.loader = loader}
        func fetch() {
            state = .loading
            loader {self.state = .success($0)}
        }
        
        func updateUI() {}
    }
}


// MARK: - Data providers
// Data providers store data that can be deserialized to their own entities
class Database {
    var data = Feeds()
}

class Network {
    var data = Feeds()
}

extension Database {
    func fetch(completion: VoidAction<Feeds>) {completion(data)}
}

extension Network {
    func fetch(completion: VoidAction<Feeds>) {completion(data)}
}


// MARK: - Main
/*
The main module imports the Network, Database and UI modules.
And assembles the app.
*/ 

// We want to be able to interact (save, fetch, etc...) with local or remote data depending on network availabilty.
// So we're goint to create FeedLoader that will perform crud actions to remote data or local data.
protocol FeedLoader {
    func load(completion: VoidAction<Main.Feeds>)
}

class RemoteFeedLoader: FeedLoader {
    let provider: Network
    init(provider: Network) {self.provider = provider}
    func load(completion: VoidAction<Main.Feeds>) {
        provider.fetch { data in
            completion(data.map {Main.Feed(id: $0.id)})
        }
    }
}

class LocalFeedLoader: FeedLoader {
    let provider: Database
    init(provider: Database) {self.provider = provider}
    func load(completion: VoidAction<Main.Feeds>) {
        provider.fetch { data in
            completion(data.map {Main.Feed(id: $0.id)})
        }
    }
}

class FeedLoaderWorker: FeedLoader {
    
    var reachability = Reachability()
    
    let remote: FeedLoader
    let local: FeedLoader
    
    init(remote: FeedLoader, local: FeedLoader) {
        self.remote = remote
        self.local  = local
    }
    
    func load(completion: (Main.Feeds) -> Void) {
        if reachability.isReachable {
            remote.load(completion: completion)
        } else {
            local.load(completion: completion)
        }
    }
    
    func loader(completion: @escaping (UI.Feeds) -> Void) {
        load {
            completion($0.map { UI.Feed(id: $0.id)})
        }
    }
}

// This represents our main target in xproject, a class for demo purposes:
class Main {
    
    // Main module imports Database & Server
    // import Database
    // import Network
    let db : Database
    let api: Network
    
    init(db: Database, api: Network) {
        self.db = db
        self.api = api
    }
    
    /// Assembler makes views and inject them their clients:
    ///
    func makeView() -> UI.FeedView {
        let remote = RemoteFeedLoader(provider: api)
        let local  = LocalFeedLoader(provider: db)
        let worker = FeedLoaderWorker(
            remote: remote, 
            local: local
        )
        return UI.FeedView(loader: worker.loader)
    }
}


let main = Main(
    db: Database(),
    api: Network()
)


func _main() {
    let view = main.makeView()
    view.fetch()
}


// Dependencies
struct Reachability {
    let isReachable = true
}

