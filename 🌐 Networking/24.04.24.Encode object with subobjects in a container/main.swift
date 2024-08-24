import Foundation

// Expected output:
let _ = """
{
  "email": "john@doe.com",
  "plainPassword": {
    "first": "1234",
    "second": "1234"
  }
}
"""

struct CreateAccountCommand {
	let email: String
	let password: String
	let repeatedPassword: String
}

extension CreateAccountCommand: Encodable  {
    
    public enum CodingKeys: String, CodingKey {
       case email
       case plainPassword
    }
    
    public enum PassCodingKeys: String, CodingKey {
        case first
        case second
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(email, forKey: .email)
        
        var passContainer = container.nestedContainer(keyedBy: PassCodingKeys.self, forKey: .plainPassword)
        try passContainer.encode(password, forKey: .first)
        try passContainer.encode(repeatedPassword, forKey: .second)
    }
}

let command = CreateAccountCommand(email: "john@doe.com", password: "1234", repeatedPassword: "1234")
let encoded = try! JSONEncoder().encode(command)
let output = String(decoding: encoded, as: UTF8.self)

print(output)