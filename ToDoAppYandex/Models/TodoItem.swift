import Foundation

struct TodoItem {
    let id: String
    let text: String
    let importance: Importance
    let deadline: Date?
    let isReady: Bool
    let createdAt: Date
    let updatedAt: Date?
    
    init(id: String = UUID().uuidString,
        text: String,
        importance: Importance,
        deadline: Date? = nil,
        isReady: Bool,
        createdAt: Date,
        updatedAt: Date? = nil) {
        self.id = id
        self.text = text
        self.importance = importance
        self.deadline = deadline
        self.isReady = isReady
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
