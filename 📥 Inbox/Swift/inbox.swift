import Foundation

// Make equatable ignore clousures: https://gist.github.com/Iron-Ham/d0eb72822f0965a3688241a70ec08f8c
struct SomeObject {
	var isFalse = true
}


// https://github.com/EvanCooper9/ECKit/blob/main/Sources/ECKit/Utility/ArrayBuilder.swift
@resultBuilder
public enum ArrayBuilder<Element> {
	public static func buildEither(first component: [Element]) -> [Element] { component }
	public static func buildEither(second component: [Element]) -> [Element] { component }
	public static func buildOptional(_ component: [Element]?) -> [Element] { component ?? [] }
	public static func buildExpression(_ expression: Element) -> [Element] { [expression] }
	public static func buildExpression(_ expression: ()) -> [Element] { [] }
	public static func buildBlock(_ components: [Element]...) -> [Element] { components.flatMap { $0 } }
	public static func buildArray(_ components: [[Element]]) -> [Element] { Array(components.joined()) }
}

public extension Array {
	static func build(@ArrayBuilder<Element> _ builder: () -> [Element]) -> [Element] {
		self.init(builder())
	}
}

let result = Array.build {
	1
	2
	3
	4
	if true { 5 }
}

print(result)