import Foundation

// MARK: - Models
struct Product { let id = UUID() }

// MARK: - States
struct CartState {
	var items = [UUID : Int]() // productId : quantity
	var total = 0
}

struct UserState {
	var isLoggedIn = false
	var userName: String?
}


struct ProductState {
	var products = [Product]()
	var isLoading = false
}

struct AppState { 
	var cart    = CartState()
	var user    = UserState()
	var product = ProductState()
}

// MARK: - Actions
enum CartAction {
	case addItem(productId: UUID)
	case removeItem(productId: UUID)
	case updateQuantity(productId: UUID, quantity: Int)
}

enum UserAction {
	case login(username: String)
	case logout
}

enum ProductAction {
	case setLoading(Bool)
	case setProducts([Product])
}

enum AppAction {
	case cart(CartAction)
	case user(UserAction)
	case product(ProductAction)
}

func cartReducer(state: CartState, action: CartAction) -> CartState { state }
func userReducer(state: UserState, action: UserAction) -> UserState { state }
func productReducer(state: ProductState, action: ProductAction) -> ProductState { state }

func appReducer(state: AppState, action: AppAction) -> AppState { 
	var newState = state
	switch action { 
		case .cart(let action): 
		newState.cart = cartReducer(state: newState.cart, action: action)
		case .user(let action):
		newState.user = userReducer(state: newState.user, action: action)
		case .product(let action):
		newState.product = productReducer(state: newState.product, action: action)
	}
	return newState
}

// MARK: - Store
final class Store {
	
	private(set) var state: AppState
	private let reducer: (AppState, AppAction) -> AppState
	
	init(state: AppState, reducer: @escaping (AppState, AppAction) -> AppState) {
		self.state = state
		self.reducer = reducer
	}
	
	func dispatch(_ action: AppAction) {
		state = reducer(state, action)
	} 
}

let store = Store(state: AppState(), reducer: appReducer)

let product = Product()

store.dispatch(.cart(.addItem(productId: product.id)))
store.dispatch(.user(.login(username: "john_doe")))
store.dispatch(.product(.setLoading(true)))