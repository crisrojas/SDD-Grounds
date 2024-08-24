import Foundation

enum State<T> {
    case idle
    case loading
    case success(T)
    case error(String)
    
    
    var isIdle: Bool {
        if case .idle = self {return true}
        return false
    }
    
    var isLoading: Bool {
        if case .loading = self {return true}
        return false
    }
    
    var isSuccess: Bool {
        if case .success = self {return true}
        return false
    }
    
    var isError: Bool {
        if case .idle = self {return true}
        return false
    }
    
    var data: T? {
        if case let .success(data) = self { return data }
        return nil
    }
    
    mutating func update(from result: Result<T, Error>) {
        self = .init(from: result)
    }
    
    init(from result: Result<T, Error>) {
        switch result {
            case .success(let t): self = .success(t)
            case .failure(let error): self = .error(error.localizedDescription)
        }
    }
}