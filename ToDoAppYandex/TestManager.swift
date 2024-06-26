import Foundation

struct TestManager {
    func test() {
        let json4ik = """
        {
          "id": "a1b2c3d4-e5f6-7g8h-9i0j-k1l2m3n4o5p6",
          "text": "Sample Todo Item",
          "importance": "важная",
          "deadline": 1657894800,
          "isReady": false,
          "createdAt": 1657891200,
          "updatedAt": 1657898400
        }
        """
        
        
        // Создание и добавление элементов
        let todoManager = FileCache()
        let todoItem1 = TodoItem(text: "Sample Todo Item 1", importance: .high, deadline: Date(timeIntervalSince1970: 1657894800), updatedAt: Date(timeIntervalSince1970: 1657898400))
        let todoItem2 = TodoItem(text: "Sample Todo Item 2", importance: .medium, deadline: Date(timeIntervalSince1970: 1657894800), updatedAt: Date(timeIntervalSince1970: 1657898400))
        todoManager.add(todoItem1)
        todoManager.add(todoItem2)

        // Сохранение в файл CSV
        todoManager.saveToCSV(filename: "TodoItems")
        print("Items saved to CSV.")

        // Загрузка из файла CSV
        todoManager.loadFromCSV(filename: "TodoItems")
        print("Items loaded from CSV:")

        // Печать загруженных элементов
        for item in todoManager.items {
            print("id: \(item.id), text: \(item.text), importance: \(item.importance.rawValue), deadline: \(item.deadline ?? Date()), isReady: \(item.isReady), createdAt: \(item.createdAt), updatedAt: \(item.updatedAt ?? Date())")
        }
       
        
    }
}
