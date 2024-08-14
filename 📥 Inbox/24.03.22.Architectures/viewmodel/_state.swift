
enum State<T> {
	case initial
	case loading
	case success(T)
	case error(String)
}

extension State { 
	init(result: Result<T, Error>) {
		switch result {
			case .success(let data): self = .success(data)
			case .failure(let error): self = .error("\(error)")
		}
	}
}
