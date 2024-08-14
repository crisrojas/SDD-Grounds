# Mostrar datos en una pantalla a partir de dos o más peticiones de red usando el patrón de delegación
#review/dev/swift

A veces el modelo de una pantalla estará compuesto de dos tipos de datos obtenidos a partir de una petición de red.

Un ejemplo sería una aplicación de cocina en la que la pantalla `LibraryScreen` muestra las últimas recetas y libros disponibles a partir de una API.

Haremos dos peticiones de red `getRecipes` y `getCookbooks` y tendremos las siguientes arrays:

```swift
var recipes: [String]?
var cookbooks: [String]?

```

Y la implementación:

```swift
func getRecipes() {
	state = .loading
	// Call implementation
}

func getCookbooks() {
	state = .loading
	// Call implementation
}

```

Al recuperar los resultados en los métodos `didGet`, poblamos esas propiedades opcionales y llamamos al método que nos servirá para mostrar los datos si ambas llamadas han sido éxitosas:

```swift
func didGetRecipes(_ result: Result<[String], Error>) {
	switch result {
	case .success(let response):
		recipes = response.recipes
		showDataIfSuccessOnBothCalls()
	case .failure(let error):
		state = .error(error.message)
	}
}

func didGetCookbooks(_ result: Result<[String], Error>) {
	switch result {
	case .success(let response):
		cookbooks = response.cookbooks
		 showDataIfSuccessOnBothCalls()
	case .failure(let error):
		state = .error(error.message)
	}
}

```

Y en el método `showDataIfSuccessOnBothCalls()` nos aseguramos de tener un valor para cada propiedad, `recipes` y `cookbooks` para poder cambiar el estado de la vista a `success` 

```swift
func showDataIfSuccessOnBothCalls() {
guard 
	let safeRecipes = recipes,
	let safeCookbooks = cookbooks
else { return }

let model = Model(
				recipes: safeRecipes, 
				cookbooks: safeCookbooks
				)

state = .success(model)
}
```

#review