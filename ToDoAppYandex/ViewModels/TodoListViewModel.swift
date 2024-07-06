import Foundation
import SwiftUI

class TodoListViewModel: ObservableObject {
    @Published var todoItems: [TodoItem] = [
//        // Дела без дедлайна
//        TodoItem(text: "Прочитать новую книгу", importance: .low, createdAt: Date().addingTimeInterval(-86400 * 5)),
//        TodoItem(text: "Обновить резюме", importance: .medium, createdAt: Date().addingTimeInterval(-86400 * 3)),
//        TodoItem(text: "Записаться к стоматологу", importance: .high, createdAt: Date().addingTimeInterval(-86400)),
//
//        // Группа 1 - дедлайн через 2 дня
//        TodoItem(text: "Купить продукты", importance: .medium, deadline: Date().addingTimeInterval(86400 * 2), createdAt: Date()),
//        TodoItem(text: "Приготовить ужин для друзей", importance: .high, deadline: Date().addingTimeInterval(86400 * 2), createdAt: Date().addingTimeInterval(-86400)),
//        TodoItem(text: "Подготовить презентацию", importance: .high, deadline: Date().addingTimeInterval(86400 * 2), createdAt: Date().addingTimeInterval(-86400 * 2)),
//
//        // Группа 2 - дедлайн через 5 дней
//        TodoItem(text: "Забрать заказ из магазина", importance: .low, deadline: Date().addingTimeInterval(86400 * 5), createdAt: Date()),
//        TodoItem(text: "Оплатить счета", importance: .high, deadline: Date().addingTimeInterval(86400 * 5), createdAt: Date().addingTimeInterval(-86400)),
//        TodoItem(text: "Подготовиться к экзамену", importance: .high, deadline: Date().addingTimeInterval(86400 * 5), createdAt: Date().addingTimeInterval(-86400 * 3)),
//
//        // Группа 3 - дедлайн через неделю
//        TodoItem(text: "Закончить проект", importance: .high, deadline: Date().addingTimeInterval(86400 * 7), createdAt: Date()),
//        TodoItem(text: "Заказать билеты в отпуск", importance: .medium, deadline: Date().addingTimeInterval(86400 * 7), createdAt: Date().addingTimeInterval(-86400 * 2)),
//        TodoItem(text: "Обновить гардероб", importance: .low, deadline: Date().addingTimeInterval(86400 * 7), createdAt: Date().addingTimeInterval(-86400 * 4)),
//
//        // Группа 4 - дедлайн через 10 дней
//        TodoItem(text: "Организовать вечеринку", importance: .medium, deadline: Date().addingTimeInterval(86400 * 10), createdAt: Date()),
//        TodoItem(text: "Пройти медосмотр", importance: .high, deadline: Date().addingTimeInterval(86400 * 10), createdAt: Date().addingTimeInterval(-86400 * 2)),
//        TodoItem(text: "Сделать уборку в гараже", importance: .low, deadline: Date().addingTimeInterval(86400 * 10), createdAt: Date().addingTimeInterval(-86400 * 5)),
//
//        // Группа 5 - дедлайн через 14 дней
//        TodoItem(text: "Подготовить отчет за квартал", importance: .high, deadline: Date().addingTimeInterval(86400 * 14), createdAt: Date()),
//        TodoItem(text: "Обновить программное обеспечение", importance: .medium, deadline: Date().addingTimeInterval(86400 * 14), createdAt: Date().addingTimeInterval(-86400 * 3)),
//        TodoItem(text: "Записаться на курсы повышения квалификации", importance: .medium, deadline: Date().addingTimeInterval(86400 * 14), createdAt: Date().addingTimeInterval(-86400 * 6)),
//
//        // Группа 6 - дедлайн через 20 дней
//        TodoItem(text: "Спланировать отпуск", importance: .medium, deadline: Date().addingTimeInterval(86400 * 20), createdAt: Date()),
//        TodoItem(text: "Подготовить презентацию для конференции", importance: .high, deadline: Date().addingTimeInterval(86400 * 20), createdAt: Date().addingTimeInterval(-86400 * 4)),
//        TodoItem(text: "Обновить портфолио", importance: .low, deadline: Date().addingTimeInterval(86400 * 20), createdAt: Date().addingTimeInterval(-86400 * 7))
    ]
    
    func addTodoItem(_ item: TodoItem) {
        todoItems.append(item)
    }
    
    func updateTodoItem(_ item: TodoItem) {
        if let index = todoItems.firstIndex(where: { $0.id == item.id }) {
            todoItems[index] = item
        }
    }
    
    func deleteTodoItem(_ item: TodoItem) {
        todoItems.removeAll { $0.id == item.id }
    }
}
