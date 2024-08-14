
protocol Persistable {}

@propertyWrapper
struct Query {
	@EnvironmentObject var persistency: Persistency
	var wrappedValue: Persistable
}


extension String: Persistable {}

// wanted api:

import SwiftUI

struct Tab: View {

	var body: some View {Text("Tab")}
}

final class Persistency: ObservableObject { 
	
}

struct App {
	let coredata = Persistency()
	let realm    = Persistency()
	let fsJson   = Persistency()
	
	var body: some View {
		Tab()
			.environmentObject(coredata)
		
	}
}