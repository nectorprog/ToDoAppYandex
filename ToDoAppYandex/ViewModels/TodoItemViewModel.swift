import SwiftUI

struct TodoItemViewModel {
    @Binding var text: String
    @Binding var importance: Importance
    @Binding var deadline: Date?
    
    var isValid: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func createTodoItem() -> TodoItem {
        TodoItem(
            text: text,
            importance: importance,
            deadline: deadline,
            createdAt: Date()
        )
    }
}
