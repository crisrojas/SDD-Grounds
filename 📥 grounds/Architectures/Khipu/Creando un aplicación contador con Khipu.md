# Creando un aplicación contador con Khipu
#review/dev/arquitectura 

* Principios de la arquitectura
  * Diseño intrínseco de una aplicación
    * UI
    * Lógica
    * State
  * Modelización
    * Lógica = AppCore > Features > UseCases
    * State    = StateStore
* Implementación de un contador
  * Creando el State
    * Creando el State
    * Creando el Store
  * Creando los UseCases
  * Creando las Features
  * Creando el AppCore
  * Persistiendo en disco
    * Serialización
    * CoreData
* Ventajas
  * Organización en *features* y *useCases*
  * Modularidad
  * Intercomunicación de las *features*

Hace poco descubrí *Khipu*, una propuesta de arquitectura de [Manual Meyer](https://vikingosegundo.gitlab.io) que consiste en una arquitectura *Clean*, con *global state* y flujo de datos unidireccional.
 
Esta son mis notas sobre como implementar la arquitectura con una aplicación básica contador.

Tenemos la vista:

```swift
struct CounterView: View {
    
    let count: Int
    
    let increase: () -> Void
    let decrease: () -> Void
    let    reset: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            HStack(spacing: 24) {
                Button("-") { decrease() }
                Text(count.description)
                Button("+") { increase() }
            }
            
            Button("Reset") { reset() }
        }
        .font(.title)
    }
}
```


### Principios de la arquitectura

El objetivo es tener un objeto o entidad que modelice la lógica de nuestra aplicación con el que podamos comunicar.

Llamémoslo *AppCore*.

Queremos enviar mensajes al *AppCore* para que este los procese y actualice el UI.

Mensaje -> *AppCore* -> Nuevo estado -> Actualización UI

Cada acción de la app, consiste en el envío de un mensaje al *AppCore.*

El *AppCore* está compuesto de funcionalidades o *features*, quienes reciben todas el mensaje, aunque solamente las funcionalidades interesadas por el mensaje actúan y actualizan el estado.

El hecho de que todas las funcionalidades reciban el estado, nos permite hacer que comuniquen entre ellas. 

Las funcionalidades están compuestas a su vez por *UseCases*, quienes actúan o no en función del mensaje.

Tenemos que el flujo es el siguiente:

Mensaje -> *AppCore* -> Funcionalidades -> UseCases -> Nuevo estado -> Actualización UI

### Modelizando los mensajes de nuestra app

Para una aplicación contador, queremos poder:

* Incrementar el contador
* Reducir el contador
* Resetear el contador

Las enumeraciones de Swift son una herramienta muy potente y el candidato perfecto para modelizar los mensajes de la app.

```swift
enum Message {
	case increase
	case decrease
	case reset
}
```

### Modelizando los UseCases

```swift
protocol UseCase {
    associatedtype RequestType
    associatedtype ResponseType
    
    func request(_ request: RequestType)
}
```

### Modelizando las Feautures

```swift
typealias Input = (Message) -> Void
```

### Modelizando el estado de la aplicación

Lo primero es modelar el *estado* de la aplicación. Podemos hacerlo con una estructura:

```swift
struct AppState { let counter: Int }
```

Nótese que la propiedad *counter* es declarada como una constante.

Esto es porque queremos un estado inmutable. Por ello, cada vez que queramos modificar nuestro contador, tendremos que regenerar una instancia de *AppState*.

Podemos modelizar los cambios de estado con una enumeración:

```swift
// MARK: - Command api
extension AppState {
	enum Change {
		case increase
		case decrease
		case reset
	}
}
```

Podemos crear un método que regenere un estado:

```swift
struct AppState {
	// ...
	func change(_ change: Change) -> Self {
		switch change {
		case .increase: .init(counter: counter + 1)
		case .decrease: .init(counter: counter - 1)
		case    .reset: .init(counter: 0          )
		}
	}
}
```


### Modelizando y creando el StateStore

Necesitaremos almacenar el estado en algún sitio.
También necesitamos de un método que permita suscribirse a los cambios de estado.

Todo esto lo haremos a través del *StateStore*, que podremos modelizar con un conjunto de tuplas.

En resumen, para el *StateStore*, necesitaremos:

* Un método para acceder al estado
* Un método para actualizar el estado
* Un método para suscribirse al estado

Todos ellos modelizables a través de aliases:

```swift
typealias   Access = () -> ApppState
typealias   Change = (AppState.Change) -> ()
typealias Callback = (@escaping () -> ()) -> ()
```

Y el *StateStore*:

```swift
typealias StateStore = (
	state: Access,
	change: Change,
	updated: Callback
)
```

Para crear el *state store* podemos utilizar una función:

```swift
func createRamStore() -> StateStore {
	var state = AppState(counter: 0) {
		didSet { callbacks.forEach { $0() }}
	}

	var callbacks = [() -> ()]()

	return (
		state: { state },
		change: { state = state.change($0} },
		updated: { callbacks.append($0) }
	)
}
```


### Creando los UseCases


```swift
struct IncreaseUseCase: UseCase {
    enum Request { case increase }
    enum Response { case didIncrease }
    
    typealias RequestType = Request
    typealias ResponseType = Response
    
    func request(_ request: Request) {
        if case .increase = request {
            store.change(.increase)
            respond(.didIncrease)
        }
    }
    
    private let store: StateStore
    private let respond: (Response) -> Void
    
    init
    (store: StateStore, responder: @escaping (Response) -> Void) {
        self.store = store
        self.respond = responder
    }
}

private func handle(_ output: @escaping Output) -> (IncreaseUseCase.Response) -> Void {{ 
    if case .didIncrease = $0 { output(.respond(.didIncrease)) }
}}

struct DecreaseUseCase: UseCase {
    enum Request { case decrease }
    enum Response { case didDecrease }
    
    typealias RequestType = Request
    typealias ResponseType = Response
    
    func request(_ request: Request) {
        if case .decrease = request {
            store.change(.decrease)
            respond(.didDecrease)
        }
    }
    
    private let store: StateStore
    private let respond: (Response) -> Void
    
    init
    (store: StateStore, responder: @escaping (Response) -> Void) {
        self.store = store
        self.respond = responder
    }
}

private func handle(_ output: @escaping Output) -> (DecreaseUseCase.Response) -> Void {{
    if case .didDecrease = $0 { }
}} 

```


### Modelizando el AppCore

- [ ] terminar artículo

```swift
typealias  Input = (Message) -> Void

func createAppCore(stateStore: StateStore) -> Input {
	
}
```


### Creando el AppCore
### Creando las Featuures

#review