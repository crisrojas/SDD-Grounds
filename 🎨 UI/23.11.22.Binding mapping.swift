import SwiftUI

protocol Voidable {}
extension Voidable {
	typealias Void = (Self) -> Swift.Void
}

extension Int: Voidable {}


extension Binding<Int> {
	var str: Binding<String> {
		Binding<String>(
			get: { self.wrappedValue.description },
			set: { self.wrappedValue = Int($0) ?? 0  }
		)
	}
}

struct AddCounter: View {
	@State var value = 0
	var create: Int.Void?
	var body: some View {
		VStack {
			TextFieldInteger("Counter", value: $value)
			Button("Create counter") {
				create?(value)
			}
		}
	}
}

struct TextFieldInteger: View {
	@Binding var value: Int
	let placeholder: String
	
	init(_ placeholder: String, value: Binding<Int>) {
		self.placeholder = placeholder
		self._value = value
	}
	
	var body: some View {
		TextField(placeholder, text: $value.str)
			//.keyboardType(.numberPad)
	}
}
