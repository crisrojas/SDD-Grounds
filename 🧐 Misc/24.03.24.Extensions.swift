extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}


extension Collection {
    func get(index: Index) -> Element? {
        self[safe: index]
    }
}

extension Array where Element: Hashable {
    func removeDuplicates() -> [Element] {
        return Array(Set(self))
    }
}

extension FloatingPoint {
    var isInteger: Bool { rounded() == self }
}
