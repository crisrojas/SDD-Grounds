import Foundation

struct ToDo: Identifiable, Equatable {
    let id: UUID
    var name: String
    var isChecked: Bool
    var projectId: UUID?
    
    init(id: UUID = UUID(), name: String, isChecked: Bool = false, projectId: UUID? = nil) {
        self.id = id
        self.name = name
        self.isChecked = isChecked
        self.projectId = projectId
    }
}

struct Project: Identifiable {
    let id: UUID
    var name: String
}