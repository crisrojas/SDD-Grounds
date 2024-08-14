# Cómo añadir un elemento a un array opcional en Swift
#review/dev/swift

Cuando manejamos arrays hay dos maneras de modelizar la ausencia de valores.

Una es usando la propiedad `isEmpty` para verificar si el array, ya inicializado, está vacío.

La otra es declarando el array como opcional y desempaquetándolo cuando lo usemos.

Un array opcional puede ser útil para verificar que una petición de red ha tenido éxito, cómo se describe en la nota: [[Mostrar datos en una pantalla a partir de dos o más peticiones de red usando el patrón de delegación]], pues no podemos usar la propiedad `isEmpty` porque la API puede devolvernos un array vacío.

El problema es cuando tenemos que implementar una paginación infinita o *infinite scroll*, pues tendremos que añadir los elementos recibidos al modelo existente en vez de reescribirlo.

Por ejemplo, si tenemos un modelo tal que:

```swift
var model: [Item]?
```

Al que queremos añadir elementos usando el método `append`, si el array opcional no ha sido inicializado, el método no funcionará y devolverá un resultado nulo.

```swift
model.append(Item()) // ❌ → Nil
```

Para poder usar el método `append` tenemos que inicializar primero el array. Si es el caso, el método `append` devolverá un resultado de tipo `Void` 

```swift
model = []
model.append(Item()) // ✅ → Void
```

Podemos aprovechar el hecho de que el método `append` puede devolver un nil para hacer una verificación:

```swift
let item = Item()
if model.append(item) == nil {
	model = [item]
}
```

En este último bloque de código estamos diciendo:

1. Si el array ya ha sido inicializado, añade el elemento
2. Si el array no ha sido inicializado, inicialízalo con el elemento -\> `model = [item]`

### Ejemplo aplicado: Infinite scroll

```swift
var page: Int = 1
var model: [Item]?

func loadMoreItemsIfNeeded() {
	getItems(page: page)
}

func didGetItems(_ result: Result<Item, Error>) {
	switch result {
	case .success(let response):
		if model.append(response.items) == nil {
			model = response.items
		}
		page += 1
	case .failure(let error):
		// ...
	}
}
```

#review
