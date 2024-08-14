import Foundation

func dp(_ any: Any) {
	#if DEBUG
	print(any)
	#endif
}

enum Method: String {
	case get, post, put, patch, delete
}

enum Task {
	// Has more cases but the ones we usually
	// and mostly use are these:
	case requestPlain
	case requestData(Data)
	case requestJSONEncodable(Encodable)
	case requestParameters(params: [String: Any])
}


protocol TargetType {
	var baseURL: URL {get}
	var path: String {get}
	var method: Method {get}
	var sampleData: Data {get}
	var task: Task {get}
	var headers: [String: String]? {get}
}

extension TargetType {
	func makeRequest() -> URLRequest {
		let url = baseURL.appendingPathComponent(path)
		var request = URLRequest(url: url)
		request.httpMethod = method.rawValue
		
		switch task {
			case .requestData(let d): 
				request.httpBody = d
			case .requestJSONEncodable(let t):
				let data = try? JSONEncoder().encode(t)
				request.httpBody = data
			default: break
		}
		return request
	}
}


struct Response {
	let statusCode: Int
	let data: Data
	
	var status: Status? {
		.init(from: statusCode)
	}
	
	enum Status: Int {
		case forbidden
		case unauhorized
		case authorized
		
		init?(from code: Int) {
			switch code {
				case 401: self = .unauhorized
				case 403: self = .forbidden
				case 200: self = .authorized
				default: return nil
			}
		}
	}
}


protocol PluginType {
	func prepare(_ request: URLRequest, target: TargetType) -> URLRequest
}

final class Provider<Target: TargetType> {
	let session: URLSession
	let plugins: [PluginType]
	
	init(session: URLSession, plugins: [PluginType]) {
		self.session = session
		self.plugins = plugins
	}
	
	func request(_ target: Target, onDone: @escaping (Result<Response, Error>) -> Void) {
		
		let request = makeRequest(with: target)
		let task = session.dataTask(with: request) { data, response, error in
			guard let data = data, error == nil else {
				onDone(.failure(NSError(domain: "\(error?.localizedDescription ?? "Unknown error")", code: 0)))
				return
			}
			
			let statusCode = (response as! HTTPURLResponse).statusCode
			onDone(.success(.init(statusCode: statusCode, data: data)))
		}	
		
		task.resume()
	}
	
	func makeRequest(with target: Target) -> URLRequest { 
		plugins.reduce(target.makeRequest()) { request, plugin in
			plugin.prepare(request, target: target)
		}
	}
}

// AUTH

enum AuthorizationType {
	case basic
	case bearer
	case custom(String)
	
	var value: String {
		switch self {
			case .basic: return "Basic"
			case .bearer: return "Bearer"
			case .custom(let customValue): return customValue
		}
	}
}


protocol AccessTokenAuthorizable {
	var authorizationType: AuthorizationType? {get}
}

struct AccessTokenPlugin: PluginType {
	let tokenClosure: (AuthorizationType) -> String
	init(tokenClosure: @escaping (AuthorizationType) -> String) {
		self.tokenClosure = tokenClosure
	}
	
	func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
		guard let type = (target as? AccessTokenAuthorizable)?.authorizationType else { return request }
		var request = request
		let authValue = type.value + " " + tokenClosure(type)
		request.addValue(authValue, forHTTPHeaderField: "Authorization")
		return request
	}
}