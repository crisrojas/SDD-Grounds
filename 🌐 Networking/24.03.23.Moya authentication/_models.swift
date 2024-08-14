import Foundation


struct Address: Codable {
	let firstName: String
	let lastName: String
	let line1: String
	let city: String
	let zipCode: String
	let phoneNumber: String
}


struct AuthToken: Decodable, Equatable {
	let accessToken: String
	let refreshToken: String
}


struct AuthCommand: Encodable {
	let grantType: String
	let clientId: String
	let clientSecret: String
	let username: EmailAddress
	let password: String
	
	init(username: EmailAddress, password: String) {
		self.username = username
		self.password = password
		grantType = password
		// @todo: This may be a insecure way of communicate with the server, this should come from a config file
		// that may be in a remote 
		// @todo: search for oauth implmentatin
		// https://stackoverflow.com/questions/1934187/oauth-secrets-in-mobile-apps
		clientId = MyApi.environment.clientId
		clientSecret = MyApi.environment.clientSecret
	}
}


/// **
/// Native email validation with rawrepresantables & NSDataDetector API
/// https://www.swiftbysundell.com/articles/validating-email-addresses/
/// **

struct EmailAddress: RawRepresentable, Encodable {
	let rawValue: String
	
	init?(rawValue: String) {
		let detector = try? NSDataDetector(
			types: NSTextCheckingResult.CheckingType.link.rawValue
		)
		
		let range = NSRange(
			rawValue.startIndex..<rawValue.endIndex,
			in: rawValue
		)
		
		let matches = detector?.matches(
			in: rawValue,
			options: [],
			range: range
		)
		
		// We only want our string to contain a single email
		// address, so if multiple matches were found, then
		// we fail our validation process and return nil:
		guard let match = matches?.first, matches?.count == 1 else {
			return nil
		}
		
		// Verify that the found link points to an email address,
		// and that its range covers the whole input string:
		guard match.url?.scheme == "mailto", match.range == range else {
			return nil
		}
		
		self.rawValue = rawValue
	}
}


// PUT command
struct RefreshAuthCommand: Encodable {
	let refreshToken: String
	let grantType: String
	let clientId: String
	let clientSecret: String
	
	init(token: String) {
		refreshToken = token
		grantType = "refresh_token"
		clientId = MyApi.environment.clientId
		clientSecret = MyApi.environment.clientSecret
	}
}
