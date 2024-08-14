
/*

Continue from [[24.03.24.Idiomatic booleans]]

Wanted api:

struct Object {
  var presented = false
}

object.is.not.presented
object.is.presented 

if object.is.not.presented {}
guard object.is.presented {}

vs 

if !object.presented {}
guard !object.presented {}

Bools don't need to be prefixed with the word "is" if they're defined using grammatic suffixes that indicates condition:
- ing
- ed 
*/

@dynamicMemberLookup
struct Is<T> {
	
	var parent: T
	
	subscript(dynamicMember member: KeyPath<T, Bool>) -> Bool {
		parent[keyPath: member]
	}
	
	var not: Not<T> { .init(parent: parent) }
	
	@dynamicMemberLookup
	struct Not<E> {
		var parent: T
		subscript(dynamicMember member: KeyPath<T, Bool>) -> Bool {
			!parent[keyPath: member]
		}
	}
}

protocol BoolVerifiable {}

extension BoolVerifiable {
	var `is`: Is<Self> { .init(parent: self) }
}

struct Object: BoolVerifiable {
	var presented = false
}

var object = Object()
print(object.is.presented) // false
print(object.is.not.presented) // true

object.presented = true
print(object.is.presented) // true

print("\n")
final class MyClass: BoolVerifiable {
	var loading = true
	var opening = false
}

let myClass = MyClass()


print(myClass.is.loading)

myClass.opening = true
myClass.loading = false

print(myClass.is.opening)
print(myClass.is.not.loading)