import XCTest
@testable import ToDoAppYandex

final class ToDoAppYandexTests: XCTestCase {

    // Массив TodoItem, который будет использоваться в тестах
        var todoItems: [TodoItem]!

        override func setUpWithError() throws {
            try super.setUpWithError()
            // Создаем объекты TodoItem для тестирования
            todoItems = [TodoItem](repeating: TodoItem(text: "Test Task", importance: .medium, isReady: false, createdAt: Date()), count: 100)
        }

        override func tearDownWithError() throws {
            // Освобождаем память
            todoItems = nil
            try super.tearDownWithError()
        }

        // Тест создания TodoItem и проверка его свойств
        func testTodoItemProperties() throws {
            let item = TodoItem(text: "Test TodoItem", importance: .high, isReady: true, createdAt: Date())
            XCTAssertEqual(item.text, "Test TodoItem")
            XCTAssertEqual(item.importance, .high)
            XCTAssertTrue(item.isReady)
        }

        // Тест сериализации в JSON и проверка условий сериализации
        func testTodoItemJsonSerialization() throws {
            let item = todoItems[0]
            let json = item.json as? [String: Any]
            XCTAssertNotNil(json)
            XCTAssertNil(json?["importance"], "Importance should not be serialized if it's medium")
            XCTAssertEqual(json?["text"] as? String, item.text)
        }

        // Тест производительности сериализации объектов в JSON
        func testPerformanceJsonSerialization() throws {
            measure {
                _ = todoItems.map { $0.json }
            }
        }

}
