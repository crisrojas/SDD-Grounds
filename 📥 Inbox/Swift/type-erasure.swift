protocol Container {
    associatedtype Element
    func get() -> Element
}

// use of protocol 'Container' as a type must be written 'any Container'
// This won't compile:
// func process(container: Container) { }

// Type erasure allows to create a type that "erases" the specific type:
struct AnyContainer<T>: Container {
    private let _get: () -> T
    
    init<C: Container>(_ container: C) where C.Element == T {
        _get = container.get
    }
    
    func get() -> T {
        return _get()
    }
}