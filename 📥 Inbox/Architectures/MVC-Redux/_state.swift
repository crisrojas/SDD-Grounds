
// MARK: - State Helpers
extension LoginState {
    
    init() { self = .initial }
    init(_ result: Result<String, LoginError>) {
        switch result {
            case .success(let username): self = .loggedIn(username: username)
            case .failure(let error): self = .error(message: error.localizedDescription)
        }
    }
    var isInitial: Bool {
        if case .initial = self { return true }
        return false
    }
    
    var statusLabel: String {
        switch self {
        case .initial:
            return "Please log in"
        case .loading:
            return "Logging in..."
        case .loggedIn(let username):
            return "Welcome, \(username)!"
        case .error(let message):
            return "Error: \(message)"
        }
    }
}
