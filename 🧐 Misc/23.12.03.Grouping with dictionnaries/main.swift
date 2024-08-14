//
//  Grouping with dictionnaries.swift
//  Effin
//
//  Created by Cristian Felipe Patiño Rojas on 03/12/2023.
//

import Foundation

/* #v-labs #misc */
import Foundation

// We have a shopping list whose items may be or not associated with an ingredient
struct ShoppingListItem {
    let name: String
    let ingredientId: UUID?
    let isChecked: Bool
}

// The ingredient is always associatd to a category:
struct Ingredient {
    let id = UUID()
    let name: String
    let categoryId: UUID
}

struct Category {
    let id = UUID()
    let name: String
}


// In our ui, we want to show the items grouped by those categories, so we consume a model like following:
struct ShoppingListSection {
    let name: String
    let items: [ShoppingListItem]
}


// We can create such an item by leveraging a native dictionnary init.
// We'll need hashable conformance:
extension Category: Hashable {}

// And a method that gets the categories of an ingredient by id:
fileprivate func getCategoryFromIngredient(id: UUID?) -> Category {
    // Must return same "unknown" symbol in both cases: guard and return coalescing
    let unknown = Category(name: "Unknown")
    
    guard
    let id = id,
    let ingredient = ingredients.first(where: { $0.id == id })
    else { return unknown }
    
    let categoryId = ingredient.categoryId
    let category   = categories.first(where: { $0.id == categoryId })
    return category ?? unknown
}

// Grouping: Returns a dictionnary of [Category: [ShoppingListItem])
let dict = Dictionary(
    grouping: shoppingListItems,
    by: { getCategoryFromIngredient(id: $0.ingredientId) }
)

// Then we can map it to the desired model:
let sections = dict.map { category, items in
    ShoppingListSection(name: category.name, items: items)
}

dump(sections.map { (name: $0.name, items: $0.items.map { $0.name }) })
