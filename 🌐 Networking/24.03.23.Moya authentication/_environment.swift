import Foundation

enum ApiEnvironment {
	case prod 
	case staging
	case dev
	case local
	
	private var _url: String {
		switch self {
			case .prod: return "https://api.myapi.com"
			case .staging: return "https://staging.myapi.com"
			case .dev: return "https://dev.myapi.com"
			case .local: return "http://localhost:8080"
		}
	}
	
	var url: URL { URL(string: _url)! }
	
	var clientId: String { 
		switch self {
			case .prod: return "prod_clientId"
			case .staging: return "staging_clientId"
			case .dev: return "dev_clientId"
			case .local: return "local_clientId"
		}
	}
	
	var clientSecret: String {
		switch self {
			case .prod: return "prod_clientSecret"
			case .staging: return "staging_clientSecret"
			case .dev: return "dev_clientSecret"
			case .local: return "local_clientSecret"
		}
	}
	
	var apiVersion: String { "1.0" }
}
