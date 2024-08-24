import Foundation

enum LoginError: Error { case credentials }
protocol LoginService {}
extension LoginService {
    func login(
        email: String, 
        pass: String, 
        onDone: @escaping (Result<String, LoginError>)
        -> Void) {
        // Simulate network call
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if email == "demo@demo.fr" && pass == "pass" {
                onDone(.success(email))
            } else {
                onDone(.failure(LoginError.credentials))
            }
        }
        
    }
}