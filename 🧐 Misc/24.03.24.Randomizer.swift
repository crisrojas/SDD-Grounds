
func randomizeFirstName() -> String {
	let firstNames = ["Ana", "Carlos", "Luis", "María", "Juan", "Sofía", "Pedro", "Laura"]
	let randomInt = Int.random(in: 0...firstNames.count - 1)
	return firstNames[randomInt]
	
}

func randomizeLastName() -> String {
	let lastNames = ["Gomez", "Perez", "Rodriguez", "Lopez", "Gonzalez", "Martinez", "Hernandez", "Diaz"]
	let randomInt = Int.random(in: 0...lastNames.count - 1)
	return lastNames[randomInt]
}
