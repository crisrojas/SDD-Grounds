/// Modelo de datos:
var categories  = [Category(name: "Carnes"), Category(name: "Lácteos"), Category(name: "Legumbres")]
var ingredients = [
    Ingredient(name: "Pollo"   , categoryId: categories[0].id),
    Ingredient(name: "Yogurt"  , categoryId: categories[1].id),
    Ingredient(name: "Queso"   , categoryId: categories[1].id),
    Ingredient(name: "Frijoles", categoryId: categories[2].id)
]

var shoppingListItems = ingredients.map { ShoppingListItem(name: $0.name, ingredientId: $0.id, isChecked: false) }

