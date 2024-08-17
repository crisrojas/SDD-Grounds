protocol EmailValidator {}
protocol PasswordValidator {}

extension EmailValidator {
    func validate(email: String) -> Bool {true}
}

extension PasswordValidator {
    func validate(password: String) -> Bool {true}
}

protocol AuthValidator: EmailValidator, PasswordValidator {}
enum ValidationError {
    case wrongEmail
    case wrongPassword
    case wrongEmailAndPassword
}
