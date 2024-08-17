

// From https://www.youtube.com/watch?v=557nJYhPb7Y
// Labeled loops
let matrix = [
	[1, 2, 3],
	[4, 5, 6],
	[7, 8, 9]
]


let valueToFind = 5
searchValue: for row in matrix { 
	for num in row {
		if num == valueToFind {
			print("Value \(valueToFind) found!")
			break searchValue
		}
	}
}
// pattern matching overload

struct Circle {
	let radius: Double
}

let circle = Circle(radius: 5)

// Multiple pattern matching Overloads so we can use them with switch:
func ~= (pattern: Double, value: Circle) -> Bool { 
	pattern == value.radius
}

func ~= (pattern: ClosedRange<Double>, value: Circle) -> Bool {
	pattern.contains(value.radius)
}


switch circle {
	case 0: print("Radius is 0, it's a point")
	case 1...10: print("Small circle with a radius between 1 and 10")
	default: print("Circle with a different radius")
}