import Foundation
import CommonCrypto

enum JWTError: Error {
	case wrongToken
	case wrongSignature
	case wrongID
	case expiredToken
	case wrongKey
	case wrongMessage
}

final class JWTManager {
	
	// Secret key used to sign the tokens
	// This shouldn't be place in code source but in environment variables or services of secrets handling
	private let secretKey = "your-secret-key"
	
	// Generates a token associated with a user
	func generateJWTToken(for userId: UUID, expirationInterval: TimeInterval) throws -> String {
		
		// This makes the token to be different on each login, which I'm not sure should be the case if
		// logins/logouts are made immediately (we should be getting the same token if logins/logouts are close in time??)
		let expirationDate = Date().addingTimeInterval(expirationInterval)
		
		let payload: [String: Any] = [
			"userId": userId.uuidString,
			"expirationDate": expirationDate.timeIntervalSince1970
		]
		
		guard let jsonData = try? JSONSerialization.data(withJSONObject: payload, options: []) else {
			fatalError("Error al codificar el payload a JSON")
		}
		
		// Encode payload
		let base64Payload = jsonData.base64EncodedString()
		
		// Sign the token
		let signature = try hmacSHA256(key: secretKey, message: base64Payload)
		
		return  "\(base64Payload).\(signature)"
	}
	
	
	func verifyAndDecodeJWTToken(_ token: String) throws -> UUID {
		
		let tokenParts = token.components(separatedBy: ".")
		
		guard tokenParts.count == 2 else { throw JWTError.wrongToken }
		
		let expectedSignature = try hmacSHA256(key: secretKey, message: tokenParts[0])
		guard tokenParts[1] == expectedSignature else { throw JWTError.wrongSignature }
		
		// Decode payload
		guard let jsonData = Data(base64Encoded: tokenParts[0]),
		let payload = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
		let userIdString = payload["userId"] as? String,
		let userId = UUID(uuidString: userIdString) else {
			throw JWTError.wrongID
		}
		
		if hasTokenExpired(token) {
			throw JWTError.expiredToken
		}
		
		return userId
	}
	
	// Generates signature from message
	// Currently, for learning purposes we're using this on each generation/verification
	// Usually, jwt frameworks handle this in a more efficient way
	private func hmacSHA256(key: String, message: String) throws -> String {
		guard let keyData = key.data(using: .utf8) else { throw JWTError.wrongKey }
		guard let messageData = message.data(using: .utf8) else { throw JWTError.wrongMessage }
		
		var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
		keyData.withUnsafeBytes { keyBytes in
			messageData.withUnsafeBytes { messageBytes in
				CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256), keyBytes.baseAddress, keyData.count, messageBytes.baseAddress, messageData.count, &digest)
			}
		}
		
		let data = Data(digest)
		return data.base64EncodedString()
	}
	
	private func hasTokenExpired(_ token: String) -> Bool {
		// Obtener el payload del token JWT
		let tokenParts = token.components(separatedBy: ".")
		guard tokenParts.count == 2, let payloadData = Data(base64Encoded: tokenParts[0]),
		let payloadJson = try? JSONSerialization.jsonObject(with: payloadData, options: []) as? [String: Any],
		let expirationTimestamp = payloadJson["expirationDate"] as? TimeInterval else {
			return true // Si no se puede obtener la fecha de expiración, consideramos que el token ha expirado
		}
		
		// Verificar si la fecha de expiración ha pasado
		let expirationDate = Date(timeIntervalSince1970: expirationTimestamp)
		return Date() > expirationDate
	}
}
