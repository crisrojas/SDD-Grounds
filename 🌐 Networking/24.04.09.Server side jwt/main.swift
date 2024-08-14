import Foundation


enum HttpMethod {
	case get, post, patch, put, delete
}

enum ServerError: Error {
	case wrongMethod
	case emailNotFound
	case wrongPassword
	case wrongToken

	case noAcccessToken
	case userAlreadyExists
}

let jsonEncoder = JSONEncoder()
let jsonDecoder = JSONDecoder()

struct AuthToken {
	let accessToken: String
	let refreshToken: String
}

struct User {
	let id: UUID
	let email: String
	let password: String
}

extension User { 
	init(email: String, password: String) {
		id = UUID()
		self.email = email
		self.password = password
	}
}


struct AccountCommand: Codable {
	let email: String
	let password: String
}

struct Recipe {
	let userId: UUID
	let name: String
}

let initialUser = User(email: "cristian@rojas.fr", password: "1234")
let initialRecipe = Recipe(userId: initialUser.id, name: "Hot Dog de Chocolate")

// Usage
final class Server { 
	
	// Database
	var users   = [initialUser]
	var recipes = [initialRecipe]	
	
	// Dependencies
	let authenticationManager = JWTManager()
	
	// Routes
	func login(method: HttpMethod = .post, payload: Data) throws -> AuthToken { 
		guard method == .post else { throw ServerError.wrongMethod }
		let command = try jsonDecoder.decode(AccountCommand.self, from: payload)
		let user = users.first(where: { $0.email == command.email })
		guard let user else { throw ServerError.emailNotFound }
		guard user.password == command.password else { throw ServerError.wrongPassword }
		
		// Generate token
		let accessToken  = try authenticationManager.generateJWTToken(for: user.id, expirationInterval: 3600)
		let refreshToken = try authenticationManager.generateJWTToken(for: user.id, expirationInterval: 3600 * 24 * 7)
		
		let authToken = AuthToken(accessToken: accessToken, refreshToken: refreshToken)
	
		
		return authToken
	}
	
	func register(method: HttpMethod = .post, payload: Data) throws -> User { 
		guard method == .post else { throw ServerError.wrongMethod }
		let command = try jsonDecoder.decode(AccountCommand.self, from: payload)
		let email = try Email(command.email)
		let password = try Password(command.password)
		
		guard users.first(where: { $0.email == command.email }) == nil else { throw ServerError.userAlreadyExists }
		let user = User(email: email.value, password: password.value)
		users.append(user)
		return user
	}
	
	// Protected route
	func recipes(method: HttpMethod, accessToken: String) throws -> [Recipe] {
		let userId = try authenticationManager.verifyAndDecodeJWTToken(accessToken)
		return recipes.filter { $0.userId == userId }
	}
}

enum ValidationError: Error {
	case invalidEmail
	case invalidPassword
}


struct Email {
	var value: String = ""
	private var error: ValidationError { .invalidEmail }
	
	init(_ v: String) throws {
		guard Self.isValid(v) else { throw error }
		value = v
	}
	static func isValid(_ value: String) -> Bool {true}
}

struct Password {
	var value: String = ""
	private var error: ValidationError { .invalidPassword }
	
	init(_ v: String) throws {
		guard Self.isValid(v) else { throw error }
		value = v
	}
	static func isValid(_ value: String) -> Bool {true}
}


final class Client {
	
	var accessToken: String?
	var refreshToken: String?
	
	let server = Server()
	
	func login(email: String, password: String) throws { 
		let command = AccountCommand(email: email, password: password)
		let payload = try jsonEncoder.encode(command)
		let authToken = try server.login(payload: payload)
		accessToken = authToken.accessToken
		refreshToken = authToken.refreshToken
	}
	
	func register(email: String, password: String) throws {
		let command = AccountCommand(email: email, password: password)
		let payload = try jsonEncoder.encode(command)
		let _ = try server.register(payload: payload)
		try login(email: email, password: password)
	}
	
	func getRecipes() throws -> [Recipe] {
		guard let accessToken else { throw ServerError.noAcccessToken }
		return try server.recipes(method: .get, accessToken: accessToken)
	}
}

let client = Client()


func test_login() throws {
	do {
		try client.login(email: "cristian@rojas.fr", password: "1234")
		let recipes = try client.getRecipes()
		print(client.accessToken!)
		print(recipes)
	} catch let error as ServerError {
		print(error)
	} catch let error as JWTError {
		print(error)
	}
}

func test_register() throws {
	do {
		try client.register(email: "cristian.rojas@live.fr", password: "some password")
		let recipes = try client.getRecipes()
		
		print(client.accessToken!)
		print(recipes)
	} catch let error as ServerError {
		print(error)
	}
}

try test_register()