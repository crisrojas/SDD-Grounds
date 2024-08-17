import SwiftUI
import Combine

struct Product: Equatable {
	let name: String
}

struct ProductView: View {
	
	@Binding var productToFavorite: Product?
	
	var body: some View {
		
		VStack {
			Button("Add to Favorite") {
				productToFavorite = Product(name: "Shirt")
			}
		}
	}
}

enum Route {
	case patient(PatientRoute)
	case product(ProductRoute)
	
	enum PatientRoute { case list }
	enum ProductRoute { case detail(Product) }
}

struct ContentView: View {
	
	@Binding var route: Route
	@State var favoritedProduct: Product?
	
	func log(_ newProduct: Product?) { 
		guard let newProduct else { return }
		print(newProduct)
	}
	
	var body: some View {
		VStack {
			Button("Login") {
				route = .patient(.list)
			}
			
			ProductView(productToFavorite: $favoritedProduct.onChange(log))
		}
	}
}


extension Binding {	
	func onChange(_ action: @escaping (Value) -> Void) -> Binding<Value> {
		return Binding<Value>(
			get: { self.wrappedValue },
			set: {
				action($0) 
				self.wrappedValue = $0
			}
		)
	}
}