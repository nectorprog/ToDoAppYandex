import Foundation

class TaskViewModel: ObservableObject {
    @Published var tasks: [TodoItem] = []

    func addTask(_ task: TodoItem) {
        tasks.append(task)
    }

    func updateTask(_ task: TodoItem) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
        }
    }

    func deleteTask(at index: Int) {
        tasks.remove(at: index)
    }
}
