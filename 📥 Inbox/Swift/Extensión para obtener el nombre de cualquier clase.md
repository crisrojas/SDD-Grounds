# Extensión para obtener el nombre de cualquier clase

#review/dev/swift

>  Aprendido durante la realización del proyecto: [[📥 Clon de Things]]

```swift
extension NSObject {
    var className: String {
        String(describing: type(of: self))
    }
    
    class var className: String {
        String(describing: self)
    }
}
```

Útil cuando necesitemos pasar el nombre de la clase por parámetro, por ejemplo, para eliminar una entidad en *CoreData*:

```swift
func delete(task: UUID) async throws {
	try await delete(TaskCD.className, id: task)
}

@discardableResult
private func delete<T: NSManagedObject>
(_ entityName: String, id: UUID) async throws -> T? {
	try await context.delete(entityName, id: id)
}
```

#review