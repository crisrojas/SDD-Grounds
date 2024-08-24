import Foundation

func async1() async {
	sleep(4)
	print("async 1")
}

func async2() async {
	print("Calling async 2")
	await async1()
	print("async 2")
}

await async2()