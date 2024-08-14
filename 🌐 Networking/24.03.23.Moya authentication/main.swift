import Foundation


enum MyApi {
	static let environment = ApiEnvironment.local
	case login(AuthCommand)
	case refreshToken(RefreshAuthCommand)
	case getAddress
}


extension MyApi: TargetType, AccessTokenAuthorizable {
	var baseURL: URL {Self.environment.url}
	
	var path: String {
		switch self {
			case .login: return "/login"
			case .refreshToken: return "/token"
			case .getAddress: return "/address"
		}
	}
	
	var method: Method {
		switch self {
			case .login: return .post
			case .refreshToken: return .put
			case .getAddress: return .get
		}
	}
	
	var sampleData: Data { Data() }
	
	var task: Task {
		switch self {
			case .login(let cmd): return .requestJSONEncodable(cmd)
			case .refreshToken(let cmd): return .requestJSONEncodable(cmd)
			case .getAddress: return .requestPlain
		}
	}
	
	var headers: [String: String]? {
		let v = "application/json;version=\(Self.environment.apiVersion)"
		return [
			"Content-Type": v,
			"Accept"      : v
		]
	}
	
	var authorizationType: AuthorizationType? {
		switch self {
		default: return .bearer
		}
	}
}

typealias Completion<T> = (Result<T, Error>) -> Void

protocol MyApiProtocol: AnyObject {
	func login(cmd: AuthCommand, onDone: @escaping Completion<AuthToken>)
	func getAddress(onDone: @escaping Completion<Address>)
}

extension Provider: MyApiProtocol where Target == MyApi {
	func login(cmd: AuthCommand, onDone: @escaping Completion<AuthToken>) {
		request(.login(cmd), onDone: { onDone($0.mapResponse()) })
	}
	
	func getAddress(onDone: @escaping Completion<Address>) {
		requestWithAuth(.getAddress, onDone: onDone)
	}
	
	private func refreshToken(_ token: String, onDone: @escaping Completion<AuthToken>) {
		let cmd = RefreshAuthCommand(token: token)
		request(.refreshToken(cmd), onDone: { onDone($0.mapResponse())}) 
	}
}

extension Provider where Target == MyApi {
	func requestWithAuth<T: Decodable>(_ target: MyApi, onDone: @escaping Completion<T>) {
		request(target) { [weak self] result in
			switch result {
				case .success(let response): 
				switch response.status {
					case .forbidden: 
						self?.logout()
						onDone(.failure(anyError()))
					case .unauhorized: 
						self?.handleUnauthorized(target, onDone: onDone)
					case .authorized:
						let decoded = try? JSONDecoder().decode(T.self, from: response.data)
						onDone(
							decoded == nil
							? .failure(anyError())
							: .success(decoded!)
						)
					default: onDone(.failure(anyError()))
				}
				
				case .failure(_): break
			}
		}
	}
	
	func logout() {
		storage.clearTokens()
		settings.isLoggedIn = false
	}
	
	func handleUnauthorized<T: Decodable>(_ target: MyApi, onDone: @escaping Completion<T>) {
		
		// If we're refresing the token...
		if settings.refreshingToken {
			// We wait till is refreshed, then we retry
			// We should have and observing mecanism here
			// so we can trigger the code once the refreshing is set to false
			// @todo: wonder if there's something wrong of doing this
			if !settings.refreshingToken {
				requestWithAuth(target, onDone: onDone)
			}
		} else {
			// If we're not refreshing the token, we
			// try to refresh it...
			settings.refreshingToken = true
			guard let token = storage.refreshToken else {
				logout()
				onDone(.failure(anyError()))
				return 
			}
			
			refreshToken(token) { [weak self] result in
				guard let self else {return}
					settings.refreshingToken = false
					switch result {
					case .success(let authToken):
						storage.saveTokens(authToken)
						self.requestWithAuth(target, onDone: onDone)
					case .failure:
						self.logout()
						onDone(.failure(anyError()))
				}
			}
		}
	}
}

extension Result where Success == Response {
	func mapResponse<T: Decodable>() -> Result<T, Error> {
		switch self {
			case .success(let r):
				let decoded = try? JSONDecoder().decode(T.self, from: r.data)
				
				return decoded == nil
				? .failure(anyError())
				: .success(decoded!)
			case .failure(let error): 
				return .failure(error)
		}
	}
}

let accessTokenPlugin = AccessTokenPlugin { _ in 
	storage.accessToken ?? "" 
}

let provider = Provider<MyApi>(
	session: .shared,
	plugins: [accessTokenPlugin]
)

let authCommand = AuthCommand(
	username: EmailAddress(rawValue: "john@doe.fr")!,
	password: "123456"
)

/*
	Client tries to access a protected route without
	being previously logged in
*/
func case1() {
	provider.getAddress { result in 
		// failure
		dump(result)
	}
}

/*
	Client performs a valid login, then tries to fetch a resource
	![](/assets/login.jpeg)
*/
func case2() {
	
	provider.login(cmd: authCommand) { result in
		switch result {
			case .success(let authToken):
			
			// Save tokens so we get address
			storage.saveTokens(authToken)
			
			// Get address
			provider.getAddress { result in 
				dump(result.data!)
			}
			
			case .failure(let error):
				print(error)
		}
	}
}

/*
	Client starts request with an old accessToken, and 
	a valid refreshToken
	![](/assets/retry-with-valid-refreshtoken.jpeg)
*/
func case3() {
	storage.accessToken = "old/invalid access token"
	storage.refreshToken = "some refreshToken"
	
	provider.getAddress { result in 
		dump(result)
	}	
}

case3()
dispatchMain()