import Foundation


enum Method {
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


protocol PluginType {}

final class Provider<Target: TargetType> {
	let session: URLSession
	let plugins: [PluginType]
	
	init(session: URLSession, plugins: [PluginType]) {
		self.session = session
		self.plugins = plugins
	}
	
	func request(_ target: Target, onDone: @escaping (Result<Response, Error>) -> Void) { 
		let url = target.baseURL.appendingPathComponent(target.path)
		let task = session.dataTask(with: url) { data, response, error in
			guard let data = data, error == nil else {
				onDone(.failure(NSError(domain: "Error al obtener los datos: \(error?.localizedDescription ?? "Unknown error")", code: 0)))
				return
			}
			
			let statusCode = (response as! HTTPURLResponse).statusCode
			onDone(.success(.init(statusCode: statusCode, data: data)))
		}	
		
		task.resume()
	}
}
