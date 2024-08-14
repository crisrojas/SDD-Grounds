import Foundation

// #vlabs #networking

// In moya you model your json api by defining an enum that mirrors its routes
enum MyApi {
	case getAddress
	case postAddress(Address)
	case putAddress(Address)
}

// We would usually want being able to configure your client to work with different envionments:

extension MyApi {
	static let environment = ApiEnvironment.local
}

// You make your enum conform to a moya protocol called `TargetType`
// And define the required vars.
extension MyApi: TargetType {
	var baseURL: URL {Self.environment.url}
	
	var path: String {
		switch self {
			case .getAddress: return "/address"
			case .postAddress: return "/address"
			case .putAddress: return "/address"
		}
	}
	
	var method: Method {
		switch self {
			case .getAddress: return .get
			case .postAddress: return .post
			case .putAddress: return .put
		}
	}
	
	var sampleData: Data { Data() }
	
	var task: Task {
		switch self {
			case .getAddress: return .requestPlain
			case
			.postAddress(let cmd), 
			.putAddress(let cmd): return .requestJSONEncodable(cmd)
		}
	}
	
	var headers: [String: String]? {
		let v = "application/json;version=\(Self.environment.apiVersion)"
		return [
			"Content-Type": v,
			"Accept"      : v
		]
	}
}

protocol MyApiProtocol: AnyObject {
	func getAddress(onDone: @escaping Completion<Address>)
	func postAddress(cmd: Address, onDone: @escaping Completion<Void>)
	func putAddress(cmd: Address, onDone: @escaping Completion<Void>)
}

extension Provider: MyApiProtocol where Target == MyApi {
	func getAddress(onDone: @escaping Completion<Address>) {
		request(.getAddress) { onDone($0.mapResponse()) }
	}
	
	func postAddress(cmd: Address, onDone: @escaping Completion<Void>) {
		request(.getAddress) { onDone($0.mapResponse()) }
	}
	
	func putAddress(cmd: Address, onDone: @escaping Completion<Void>) {
		request(.getAddress) { onDone($0.mapResponse()) }
	}
}


extension Result where Success == Response {
	func mapResponse<T: Decodable>() -> Result<T, Error> {
		switch self {
			case .success(let response):
			do {
				let object = try JSONDecoder().decode(T.self, from: response.data)
				return .success(object)
			} catch {
				return .failure(error)
			}
			case .failure(let error): return .failure(error)
		}
	}
	
	func mapResponse() -> Result<Void, Error> {
		switch self {
			case .success(let response):
			// you may want to switch over response.status for having granular control over Error mapping
				if response.statusCode == 200 {
					return .success(())
				} else {
					return .failure(anyError())
				}
			case .failure(let error): return .failure(error)
		}
	}
}

// Usage:
let provider = Provider<MyApi>(session: .shared, plugins: [])

provider.getAddress { result in
	guard let data = result.data else { print("Start json-server") ; return }
	dump(data)
}

// Needed to dispatch to main: https://developer.apple.com/forums/thread/713085
dispatchMain()