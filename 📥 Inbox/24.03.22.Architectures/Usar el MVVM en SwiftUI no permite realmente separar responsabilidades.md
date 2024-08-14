# Usar el MVVM en SwiftUI no permite realmente separar responsabilidades
#review/dev/swift #review/dev/arquitectura

Digamos que tenemos una aplicación contador muy sencilla.

```swift
struct ContentView: View {
    @State private var counter = 0
    var body: some View {
        VStack(spacing: 24) {
            HStack(spacing: 24) {
                Button("-") { counter -= 1 }
                Text(counter.description)
                Button("+") { counter += 1 } 
            }
            
            Button("Reset") { counter = 0 }
        }
			.font(.title)
    }
}
```


### ViewModel

Si usamos el patrón MVVM, tendríamos algo así:

**Vista**

```swift
struct CounterView: View {
    @StateObject var viewModel = CounterViewModel()
    var body: some View {
        VStack(spacing: 24) {
            HStack(spacing: 24) {
                Button("-") { viewModel.decrease() }
                Text(viewModel.count.description)
                Button("+") { viewModel.increase() }
            }
            
            Button("Reset") { viewModel.reset() }
        }
        .font(.title)
    }
}
```

**ViewModel:**

```swift
final class CounterViewModel: ObservableObject {
    @Published var count = 0
    
    func increase() { count += 1 }
    func decrease() { count -= 1 }
    func    reset() { count  = 0 }
}
```

El *viewModel* tiene la responsabilidad de hacer todo lo necesario para que la vista se dibuje, aportándole su estado.

El problema es que la vista es dueña del *viewModel*.

Esto no es tan grave para una aplicación tan sencilla. Pero...

Digamos que el estado de la vista viene de la web, y para modificarlo y obtenerlo tenemos que llamar a un web servicio.

Podemos modelar el web servicio con un protocolo. 
Protocolo + implementación:

```swift

var remoteApiCount = 3

protocol ICountService {
    func getCount() async -> Int
    func increase() async
    func decrease() async
    func reset() async
}

final class CountService: ICountService {
    func getCount() async -> Int { remoteApiCount }
    func increase() async { remoteApiCount += 1 }
    func decrease() async { remoteApiCount -= 1 }
    func    reset() async { remoteApiCount  = 0 }
}
```


El *viewModel* quedaría así:

```swift
final class CounterViewModel: ObservableObject {

    @Published var count = 0
    
    private let service: ICountService
    
    init(service: ICountService = CountService()) {
        self.service = service
    }
    
    func getData() async { 
		count = await service.getCount()
    }
    
    func increase() {
        Task {
            await service.increase()
            await getData()
        }
    }
    
    func decrease() { 
        Task {
            await service.decrease()
            await getData()
        }
    }
    
    func reset() { 
        Task {
            await service.reset()
            await getData()
        }
    }
}
```

Para recuperar los datos al cargar la vista, usamos el modificador `.task { }`, que permite llamar funciones asíncronas:

```swift
struct CounterView: View {
    @StateObject var viewModel = CounterViewModel()
    var body: some View {
        VStack(spacing: 24) {
            HStack(spacing: 24) {
                Button("-") { viewModel.decrease() }
                Text(viewModel.count.description)
                Button("+") { viewModel.increase() }
            }
            
            Button("Reset") { viewModel.reset() }
        }
        .font(.title)
        .task { await viewModel.getData() }
    }
}
```


Esta es la implementación clásica del patrón MVVM, usada en todos los tutoriales que he encontrado.

Observamos que ahora la vista está ligada a la lógica del web servicio (incluso si usamos un protocolo, el nombre es bastante específico).

Si quisiésemos reutilizar la vista en otro proyecto, o simplemente iterar probando otra arquitectura  (Redux, Khipu, TCA, etc...) tendríamos que hacer una refactorización importante.

En el caso de vistas complejas, puede llegar a ser mejor reescribirla desde cero.

> EDIT 2023-03-08: En realidad no está tan ligada a la lógica del web servicio  cómo creía en un principio, pues se puede implementar un objeto diferente que conforme al protocolo e inyectarlo en el viewModel al construirlo. Tal vez sería más pertinente hablar de *repositorio* en lugar de *servicio*,  porque los datos pueden venir de cualquier lugar: una base de datos local, userDefaults, etc…

### Proposición

La solución que se me ocurre es crear vistas lo más "tontas" posibles.

Así, para nuestro ejemplo, no tendríamos un `@State var count = 0`, sino un `let count: Int`.

Los cambios de estado que disparan la recreación de la vista son externos y no internos. Al menos para las propiedades que contengan datos y no estados necesarios al diseño de interfaz.

Estos últimos pueden y deben, en mi opinión, ir en la vista en la vista.

> EDIT 2023-04-07: Matteo Manferdini también está de acuerdo;
> Views should not store the app’s state. The @State property wrapper of SwiftUI exists only for local state related to the user interface —[Matteo Manferdini, Mode-View-Controller in iOS/A Blueprint for Better Apps](https://matteomanferdini.com/model-view-controller-ios/);

Hablo por ejemplo de `@FocusState` para los textfields, o una variable `@State` que contenga un color que puede ser mutado desde la vista.

```swift
typealias SimpleAction = () -> ()

struct CounterView: View {
    
    let count: Int
    
    let increase: SimpleAction
    let decrease: SimpleAction
    let    reset: SimpleAction
    
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

Ahora el estado viene de afuera, la vista ya no es dueña de su *viewModel*.

Si queremos usar un *viewModel*, tendremos que crear una vista que sea dueña del *viewModel*, declarado como *@StateObject* para que los cambios re-dibujen la vista.


```swift
struct CounterViewWrapper: View {
    
	@StateObject private var vm = CounterViewModel()
    
    var body: some View {
        CounterView(
            count: vm.count, 
            increase: vm.increase, 
            decrease: vm.decrease, 
            reset: vm.reset
        )
        .task { await vm.getData() }
    }
}
```


- - -
> EDIT 2023-03-08: Viendo los vídeos de *Essential Developer* (ver: [[2023-03-08 Camino a Senior++]]), me doy cuenta de que no necesito de un wrapper. Puedo utilizar un protocolo:

```swift
protocol ICounterHandler {
	func getCounter() async -> Int
	func increase() async -> Int
	func decrease() async -> Int
}

struct CounterView: View {
    
	  @State private var count = 0
	  let handler: ICounterHandler

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
		  .task {
			 count = await handler.getCounter()
		  }
    }
    
	  func increase() { Task {
		count = await increase()
	  }}

	  func decrease() { Task {
		count = await decrease()
	  }}
}

```

- - -
También podemos usar un estado global:

```swift
final class AppState: ObservableObject {
	@Published var count = 0

	// ... Other states ...
	@Published var articles: [Article] = []
	@Published var someOtherState: [String] = []
}

final class MyApp: App {
   
    @StateObject private var appState = GlobalState()
    
    var body: some Scene {
        WindowGroup {
            MainView().environmentObject(appState)
        }
    }
}

struct MainView: View {
    @EnvironmentObject private var state: GlobalState
    
    var body: some View {
        CounterView(
            count: state.count, 
            increase: { state.count += 1 },
            decrease: { state.count -= 1 }, 
               reset: { state.count  = 0 }
        )
    }
}
```


#### Desventajas de utilizar vistas agnósticas que sólo toman closures

La desventaja principal que he encontrado es que, cuando tenemos una jerarquía de navegación, vamos a tener que pasar a la primera vista las acciones de la segunda.

Por ejemplo, el caso típico es que tengamos una lista de elementos. 

```swift

struct Item: Identifiable { 
    let id: UUID
    var name: String
}

struct ListScreen {
    let model: [Item]
    var body: some View {
        List(model) {Text($0.name)}
    }
}
```

Cuando el usuario hace *tap* en un elemento de la lista, queremos presentar una pantalla, `EditItemScreen`, que permita al usuario editar el elemento:


```swift
struct EditItemScreen: View {
    
    @State var name: String = ""
    let id: UUID
    let save: (UUID, String) -> Void
    
    var body: some View {
        Form { TextField("Name", text: $name) }
        .toolbar { 
            Button("Save") { save(id, name) }
        }
    }
}
```


Instanciamos la vista `EditItemScreen` desde la vista `ListScreen`, por tanto toda la información de `EditItemScreen`, tiene que ser inyectada a de antemano a  `ListScreen` (esto incluye la acción *save* o cualquier otra acción que `EditItemScreen` quiera ejecutar)

Por lo tanto, cuánto más profunda sea la jerarquía, más acciones tendremos que pasar a los niveles superiores.

Tenemos la jerarquía siguiente:

*MyApp* -> *MainView* -> *ListScreen* -> *EditItemScreen*

*MyApp* contiene la fuente de verdad, que es transmitida a las vistas inferiores.

```swift
@main
final class MyApp: App {
        
    @StateObject var state = GlobalState()
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                MainView().environmentObject(state)
            }
        }
    }
}
```


*MainView*


```swift
struct MainView: View {
    @EnvironmentObject private var state: GlobalState
    
    var body: some View {
        ListView(
				model: state.items,
				edit: edit(itemId:name:)
			)
    }
    
    func edit(itemId: UUID, name: String) {
        let index = state.items.firstIndex(where: { $0.id == itemId })!
        state.items[index].name = name
    }
}
```

ListView

```swift

struct ListScreen: View {
    
    let model: [Item]
    let edit: (UUID, String) -> Void
    
    var body: some View {
        List(model) { item in
            NavigationLink { 
                EditItemScreen(
                    id: item.id,
                    edit: edit
                )
            } label: {
                Text(item.name)
            }
        }
    }
}
```

#review
