# Implementando enumeraciones con tuplas en lenguajes de programación sin soporte

#dev

En Swift tenemos soporte para enumeraciones con tuplas, lo que permite, por ejemplo, modelizar el estado de una vista que cargue sus datos de forma asíncrona mediante un enum, la implementación sería algo así:

```swift
enum State<T> {
	case loading
	case success(T)
	case error(String)
}
```

Y el uso en la vista sería así:

```swift
struct Item {}
struct MyView: View {
	@State private var state = State<[Item]>.loading
	var body: some View {
		Group {
			switch state {
			case .loading: ProgressView()
			case .error(let message): Text(message)
			case .success(let data): listView(data)
			}
		}
		.task {
			state = .loading
			let items = await someService.getItems()
			state = .success(items)
		}
	}
	
	func listView(_ data: [Item]) -> some View { /*...*/ }
}
```


Los enums con tuplas me son extremadamente útiles y me sirvo de ellos sin moderación ni remordimiento.  Los eché mucho de menos cuando coqueteé con `SvelteKit` (javascript) para el primer prototipo de [[🐻‍❄️ BearKit]].

### Implementación alternativa

Este es mi intento de implementación de una estructura de datos que funcione de forma similar. a un enum con tuplas. 

Lo implementé primero en Swift por comodidad (javascript me cuesta todavía):

```swift
struct State<T> {
    var idle: Bool { success == nil && error == nil }
    let error: String?
    let success: T?
    
    init(error: String? = nil, success: T? = nil) {
        self.error = error
        self.success = success
    }
    
    static func loading() -> Self {
        .init()
    }
    
    static func error(_ error: String)  -> Self {
        .init(error: error)
    }
    
    static func success(_ success: T) -> Self {
        .init(success: success)
    }
    
    func _switch(
        caseLoading: () -> Void,
        caseSuccess: (T) -> Void,
        caseError: (String) -> Void
    ) {
        if idle {
            caseLoading()
        } else if let successValue = success {
            caseSuccess(successValue)
        } else if let error = error {
            caseError(error)
        }
    }
}
```


#### Uso

Aunque no tiene sentido usar esto en Swift, se vería de esta manera:

```swift
// UIKit
final class View {
    
    var state = State<[Item]>.loading() {
        didSet {
            state._switch(
                caseLoading: { setLoading() },
                caseSuccess: { setSuccess($0 },
                caseError: { setError($0 }
            )
        }
    }
    
    func load() {
        state = .loading()
        someService.getItems { [weak self] result in
            guard let self else { return }
			switch result {
			case .failure(let error): 
				self.state = .error(error.message)
			case .success(let items)
     		    self.state = .success(items)
			}
        }
    }
}

// SwiftUI
struct ContentView: View {
    @State private var state = ViewState<[Item]>.loading()
    var body: some View {
        Group {
            view()
        }
        .task {
            state = .loading()
            state = .success([])
        }
    }
    
    func listView(_ data: [Item]) -> some View {
        Text("Success")
    }
    
    func view() -> some View {
        var view = AnyView(self)
        state._switch {
             view = AnyView(ProgressView())
        } caseSuccess: { _ in
            view = AnyView(Text("Success"))
        } caseError: { error in
            view = AnyView(Text(error))
        }
        return view
    }
}
```


### Traducción a javascript

Cortesía de ChatGPT 🤖

```js
class State {
    constructor(error = null, success = null) {
        this.error = error;
        this.success = success;
    }

    get idle() {
        return this.success === null && this.error === null;
    }

    loading() {
        return new State();
    }

    setError(error) {
        return new State(error);
    }

    setSuccess(success) {
        return new State(null, success);
    }

    switchCases(caseLoading, caseSuccess, caseError) {
        if (this.idle) {
            caseLoading();
        } else if (this.success !== null) {
            caseSuccess(this.success);
        } else if (this.error !== null) {
            caseError(this.error);
        }
    }
}

class View {
    constructor() {
        this.state = new State();
    }

    load() {
        this.state = this.state.loading();
        setTimeout(() => {
            this.state = this.state.setSuccess([]);
        }, 3000);
    }
}

// Ejemplo de uso
const view = new View();
view.load();

view.state.switchCases(
    () => {
        console.log("Loading...");
    },
    (success) => {
        console.log("Success:", success);
    },
    (error) => {
        console.log("Error:", error);
    }
);
```