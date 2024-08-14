# Cómo refactorizar listas asíncronas en SwiftUI con extensión de protocolos

#review/dev/swift #review/privado #review/🖋️ #📥

Es común en una app que tengamos que cargar una lista de elementos desde el servidor.

Este es un ejemplo real de una app en la que trabajé y en la que modelamos el estado de la vista con un *enum* `State`:

@todo: Ejemplo de Menuz.swift:

```swift
```

Muchas de las pantallas de la app utilizan el mismo patrón: 

- Un estado
- Una función que recupera los datos de forma remota y muta el estado
- Un `switch` del estado para mostrar una vista diferente por cada fase

Durante esa época en la que apenas empezaba a meter las patas en la profesión, siempre me pregunté si no había una manera de refactorizar, la respuesta la tiene la programación orientada a protocolos y una *feature* única en *Swift*: la extensión de protocolos.

Entre otras cosas, algunos buenos artículos que me han servido para introducirme a este paradigma han sido estos:

- Manferdini -> arquitectura de networking
- Jam li -> ? (El estilo de este autor es muy ácido y crítico con las convenciones aceptadas comúnmente como buenas prácticas, no apto para personas sensibles 😉)

Antes de que veamos cómo refactorizar la lógica con un protocolo, me gustaría revisitar el enum `State`,  para aportar algunas mejoras y correcciones al uso que le dimos en aquel proyecto.

### ListState<T>

// @todo: citar a swift by Sundell

#### Genéricos

En nuestros proyectos solíamos tener un enum `State` para cada vista, algo como:

```swift
struct View1: View { 
	enum State {
		case idle
		case loading
		case success(View1Model)
		case error(String)
	}
}

struct View2: View { 
	enum State {
		// ...
		case success(View2Model)
	}
}

// View3, View4, View5, etc...
```

Era una estrategia tediosa y repetitiva. Se podría simplificar con genéricos:

```swift
enum State<T> {
	case idle
	case loading
	case success(T)
	case error(String)
}
```


#### State<T> vs ListState<T>

Algo que solíamos hacer para aquellas vistas que contenían listas, es modelar el state con un caso vacío. 

Como sólo queremos ese caso para las vistas que tengan listas, distinguiremos entre `State<T>` y `ListState<T>`:

```swift
enum ListState<T> {
	case idle
	case loading
	case success([T])
	case error(String)
	case empty
}
```


#### Caso `empty` y constructor por defecto

Otro error común en el proyecto, es que solíamos tener una lógica para determinar si el estado de la lista debía ser *vacío* o exitoso antes de construirlo:

```swift
final class ViewModel { 
	@Published var state: State = .idle
	func fetchData() async { 
		let data = await api.getData()
		if data.isEmpty {
			state = .empty
		} else {
			state = .success(data)
		}
	}
}
```

Podemos mover esa lógica directamente al propio estado:

```swift
enum ListState<T> {
	// ... cases ...
	init(from items: [T]) {
		if items.isEmpty { self = .empty }
		else { self = .success(items) }
	}
}
```

Lo que simplifica la construcción del estado:

```swift
final class ViewModel { 
	@Published var state: State = .idle
	func fetchData() async { 
		let data = await api.getData()
		state = .init(from: data)
	}
}
```

### ListView Protocol

Teniendo en cuenta estos cambios al enum `ListState`, podemos empezar a modelar el protocolo al que conformarán nuestras listas.

¿Cuáles son los elementos comunes a una lista asíncrona? 

Una lista siempre tiene:

1. Un estado
2. Una función que recupera los datos y construye con ellos el estado
3. Una vista para cada estado
4. Una vista que es función del estado y que devuelve siempre sólo una de las vistas del punto 3.

Como primera implementación, podríamos pensar en algo así:

```swift
protocol ListView: View {
    associatedtype ModelType: Identifiable
    var state: ListState<ModelType> { get }
    func loadItems() async
}

extension ListView {
    var loadingView: some View { 
		ProgressView().task { await load() }
 	}

    var emptyView: some View { Text("No items found") }
    func error(_ message: String) -> some View { Text(message) }
    func list(_ items: [ModelType]) -> some View { /* ... */ }
    
    @ViewBuilder
    var viewFromListState: some View {
        switch state {
        case .idle, .loading: loadingView
        case .error(let message): error(message)
        case .success(let items): list(items)
        default: emptyView
        }
    }
```

Podemos proveer también una implementación por defecto del método `list(_ items:)` , para ello necesitamos añadir un nuevo requisito al protocolo: Una vista que nos devuelva una celda de la lista ->

```swift
protocol ListView: View {
    associatedtype CellType: View
	// ...
	func cell(item: ItemType) -> CellType
} 
```

Consumimos la celda:

``` swift
extension ListView {
	func list(_ items: [ModelType]) -> some View {
		List(items) { cell($0) }
    }
}
```

Para poner la guinda sobre el pastel, podemos proveer una definición por defecto del `body` de la vista:

```swift
extension ListView {
	var body: some View { viewFromListState }
}
```

### Uso

```swift
struct Feed: ListView {
    @State var state = ListState<Item>.idle
    
    func row(_ item: Item) -> some View {
        NavigationLink {
            FeedDetail(
                id: item.id,
                title: item.title,
                subtitle: item.subtitle
            )
        } label: {
            Text(item.title)
            Text(item.subtitle)
        }
    }
    
    func loadItems() async {
        state = .loading
		let resource = FeedResource()
        let items = await APIRequest(resource).execute()
        state = .init(from: items)
    }
}

struct FeedDetail: ListView {
    @State var state = ListState<Comment>.idle
    let id: UUID
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack {
            Text(title)
            Text(subtitle)
			Text(commentCount)
            viewFromListState
        }
    }
	    
    func row(_ item: Comment) -> some View {
        VStack {
			Text(item.author)
            Text(item.comment)
        }
    }
    
    func loadItems() async {
        state = .loading
		let resource = CommentsResource(feedId: id)
		let items = await APIRequest(resource).execute()
        state = .init(from: items)
    }
}

// UI Models
extension Feed {
    struct Item: Identifiable {
        let id: UUID
        let title: String
        let subtitle: String
        let commentCount: String
    }
}

extension FeedDetail {
    struct Comment: Identifiable {
        let id: UUID
		let author: String
        let comment: String
    }
}

```

### Uso con ViewModel/Presenter/Store/Etc…


```swift
struct Feed: ListView {
    @State var model = Model()

    var state: ListState<Feed.Item> {
		model.state
	}
    
    func row(_ item: Feed.Item) -> some View { /* ... */ }
    
    func loadItems() async {
        await model.load()
    }
}

extension Feed {
    @Observable final class Model {
        var state = ListState<Feed.Item>.idle
        
        @MainActor func load() async {
            state = .loading
			let items = await APIRequest(resource: FeedResource()).execute()
            state = .init(from: items)
        }
    }
}

```

### 🍳🍳🍳

```swift
import SwiftUI

enum ListState<T: Identifiable> {
    case idle
    case loading
    case success([T])
    case empty
    case error(String)
    
    init(from list: [T]) {
        if list.isEmpty { self = .empty } else { self = .success(list) }
    }
}

protocol ListView: View {
    associatedtype ItemType: Identifiable
    associatedtype RowView: View
    var state: ListState<ItemType> { get }
    func loadItems() async
    func row(_ item: ItemType) -> RowView
}

extension ListView {
    @ViewBuilder
    var list: some View {
        switch state {
        case .idle, .loading: ProgressView().task { await loadItems() }
        case .empty: Text("Empty list")
        case .success(let items): list(items)
        case .error(let message): Error(message: message)
        }
    }
    
    func list(_ items: [ItemType]) -> some View {
        List(items) { row($0) }
    }
    
    var body: some View { list }
}
```

#review