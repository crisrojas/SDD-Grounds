// MARK: - Mappable
protocol Mappable {}
extension Mappable {
    func map(transform: (inout Self) -> Void) -> Self {
        // We are returning a new instance so meant to be used
        // with strcuts
        var new = self
        transform(&new)
        return new
    }
}