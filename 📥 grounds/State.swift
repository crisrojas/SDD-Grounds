import Foundation

enum State<T> {
	case idle, loading, success(T), failure(String)
}

extension State {
	init() { self = .idle }
	var data: T? {
		if case let .success(data) = self { return data }
		return nil
	}
	
	func map<B>(completion: @escaping (T) -> B) -> B? {
		guard let data else { return nil }
		return completion(data)
	}
	
	init(_ result: Result<T, Error>) {
		switch result {
			case .success(let data): self = .success(data)
			case .failure(let error): self = .failure(error.localizedDescription)
		}
	}
}