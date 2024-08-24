import Foundation
import Observation

@Observable class User {
	var name: String
	var age: Int
	
	init(name: String, age: Int) {
		self.name = name
		self.age  = age
	}
}

let user = User(name: "Cristian", age: 32)

_ = withObservationTracking {
	user.age
} onChange: { 
	DispatchQueue.main.async {
		print("Happy birthday: \(user.age)")
	}
}


user.age += 1



func observeAge() {
	_ = withObservationTracking {
		user.age
	} onChange: { 
		DispatchQueue.main.async {
			observeAge()
		}
	}
}

observeAge()
user.age += 1
user.age += 1
user.age += 1

dispatchMain()