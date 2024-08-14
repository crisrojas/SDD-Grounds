//
//  Mutations and copies rationale.swift
//  PlaygroundsTests
//
//  Created by Cristian Felipe Patiño Rojas on 14/12/2023.
//

import Foundation

/*
When updating a item persisted in a datastore, we usually end with many updated methods.

For example, let say you have an ingredients object:
*/
struct ShoppingListItem: Identifiable, Equatable  {
  let id: Int
  var name: String
  var isChecked: Bool
  var measureUnitId: Int?
  var quantity: Double
  var updatedAt: Date
}

// You may end with an api like this.
protocol LocalPersistenceAPI {
    func updateItem(with id: Int, title: String?)
    func updateItem(with id: Int, isChecked: Bool?)
    func updateItem(with id: Int, quantity: Double?)
    func updateItem(with id: Int, measureUnitId: Int?)
    func updateItem(with id: Int, ingredientId: Int?)
    func updateItem(with id: Int, updatedAt: Date?)
}


// That's a bit verbose.
//
// A single method is all you need:
//
func update(ingredient: ShoppingListItem) {}

/*
This would be our update entry point.

The goal of the mutable protocol plagrounds is to come up with an api that allows modification of conformers by returning a new instance so we can encapsulate changes and pass it to such an entry point, so we won't need more than a method.

Ex.)

```swift
let updatedItem = item
.update(.name("chicken"))
.udpate(.listId(24))

persistencySolution.update(updatedItem)
```
*/

// MARK: - SwiftUI

/*
Would be this necessary in SwiftUI?

No, as it can directly modify the item  (as you have direct bindings that do the job for you):
*/
struct ItemEdit: View {
    @State var item: ShoppingListItem
    var persist: ((ShoppingListItem) -> Void)?
    var body: some View {
        VStack {
            /// Textfield input directly modifies the item.
            TextField("name", text: $item.name)
            Button("Save") {
                persist?(item)
            }
        }
    }
}

// MARK: - UIKit
/*
Would this be necessary in UIKit?

Nope, this seems coherent to me:
*/
class ItemEditVC {
    var item: ShoppingListItem!
    var textField: UITextField!
    var saveButton: UIButton!
    var persist: ((ShoppingListItem) -> Void)?

    func viewDidLoad() {
        textField.delegate = self
    }

    func didTapSaveButton() {
        persist?(item)
    }

    func textFieldDidBeginEditing(textField: UITextField!) {
        item.name = textField.text
    }
}

// MARK: - Global Store

/*
Would this be necesary if we use a global store (Redux, Khipu, TCA...)?

Nope, I've just realized and update api isn't necessary:
*/
struct AppState {
    var items: [ShoppingListItem] = []

    enum Update {
        // You usually would want create & delete commands too. 
        // For simplicity, lets keep just the update one:
        case update(ShoppingListItem)
    }

    func update(_ update: Update) {
        /// Perform some changes depending on update
        /// Then return updated item
    }
}

class KhipuStore: ObservableObject {
    @Published var appState = AppState()
    func receive(_ update: AppState.Update) {
        appState.update(update)
    }
}

struct ItemList: View {
    @StateObject var store = KhipuStore()
    var body: some View {
        List(store.appState.items) { item in
            NavigationLink {
                ItemEdit(item: item, persist: persist)
            } label: {
                Text(item.name)
            }
        }
    }

    func persist(item: ShoppingListItem) {
        store.receive(.update(item))
    }
}


// MARK: - Syntax exploration
protocol Updater {
    associatedtype T
    static func update<V>(_ type: T, _ kp: WritableKeyPath<T, V>, with value: V)
}

extension Updater {
    static func update<V>(_ type: T, _ kp: WritableKeyPath<T, V>, with value: V) {
        var copy = type
        copy[keyPath: kp] = value
        /// do something with updated copy
    }
}

struct Person: Mappable, KeyPathMutable {
    var firstName: String
    var lastName: String
}


import SwiftUI
struct TestView: View {
    @State var person = Person(firstName: "cristian", lastName: "rojas")
    @State private var firstName: String
    @State private var lastName: String
    
    var persist: ((Person) -> Void)?
    
    var body: some View {
        VStack {
            VStack {
                TextField(firstName, text: $firstName)
                TextField(lastName , text: $lastName )
            }
            
            Button("Change name") {
                
                // - Copy making
                //
                // Mapped seems more useful than keyPath for this urpose as it allows
                // multiple changes in the same closure, so you don't really have to chain changes
                person = person.map {
                    $0.firstName = firstName
                    $0.lastName = lastName
                }
                
                persist?(person)
            }
        }
    }
    
    // This would be still redundant with SwiftUI as you can
    // just do:
    var body_bis: some View {
        VStack {
            VStack {
                TextField(person.firstName, text: $person.firstName)
                TextField(person.lastName , text: $person.lastName )
            }
            
            Button("Change name") {
                persist?(person)
            }
        }
    }
}
/*

Copy making could be useful for dependency/injection chaging variables.

That allows simplifiying deeply dev experience and improves speed.

For example, lets say we have a view, which has some initial configuration
*/
struct ProfileView: View {
    enum PrivacyLevel {
        case friend
        case friendsFriend
        case stranger
    }
    
    var privacyLevel = PrivacyLevel.friend
    var body: some View {
        VStack {/* Implementation */}
    }
}


/*
We could inject privacyLevel through init and give it a default value there:


`init(privacyLevel: PrivacyLevel = .friend) {}`

However, this becomes tedious the more you properties you have in your view as you will have to manually gave default values on init.
*/

// Is way easer to declare de value as a var, then conform the struct
// to our little protocol:
extension ProfileView: KeyPathMutable {}


/*
With a copy making approach you can inject values if you need to change them before making something with the object:
*/
let profile = ProfileView()
    .injecting(\.privacyLevel, .stranger)
