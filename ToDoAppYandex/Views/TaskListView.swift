import SwiftUI

struct TaskListView: View {
    var tasks: [TodoItem]
    var onDelete: (Int) -> Void
    var onEdit: (Int) -> Void
    var onToggleReady: (Int) -> Void

    var body: some View {
        List {
            ForEach(Array(tasks.enumerated()), id: \.element.id) { index, task in
                TaskRowView(task: task, onDelete: { onDelete(index) }, onEdit: { onEdit(index) }, onToggleReady: { onToggleReady(index) })
            }
        }
        .listStyle(PlainListStyle())
    }
}

#Preview {
    TaskListView(tasks: [
        TodoItem(text: "Купить сыр", importance: .medium, createdAt: Date(timeIntervalSinceNow: -10000)),
        TodoItem(text: "Сделать пиццу", importance: .low, isReady: true, createdAt: Date(timeIntervalSinceNow: -5000)),
        TodoItem(text: "Задание", importance: .high, deadline: Date(), createdAt: Date(timeIntervalSinceNow: -2000))
    ], onDelete: { _ in }, onEdit: { _ in }, onToggleReady: { _ in })
}
