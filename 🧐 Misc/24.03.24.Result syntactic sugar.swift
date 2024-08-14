import Foundation

typealias Result<T> = Swift.Result<T, Error>
typealias ResultCls<T> = (Result<T>) -> Void

extension Result {
	var data: Success? {
		if case let .success(data) = self { return data }
		return nil
	}
}

enum ViewState<T> {
	case loading
	case success(T)
	case error(String)
}

extension ViewState {
	init(from result: Result<T>) {
		switch result {
			case .success(let data): self = .success(data)
			case .failure(let error): self = .error(error.localizedDescription)
		}
	}
}

func doSomething(onDone: ResultCls<String>) {
	onDone(.success("Done"))
}

doSomething { result in
	print(result.data!)
}
