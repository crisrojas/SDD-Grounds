import Foundation

protocol Fetcher {}
extension Fetcher {
	var session: URLSession { URLSession.shared }
	
	func fetch<T: Decodable>(url: URL, completion: @escaping (Result<T, Error>) -> Void) {}
}