import XCTest
@testable import ToDoAppYandex

final class ToDoAppYandexTests: XCTestCase {
    
    // Постоянные даты для тестирования
    let fixedCreatedAt = Date(timeIntervalSince1970: 1609459200) // 1 Jan 2021 00:00:00 GMT
    let fixedDeadline = Date(timeIntervalSince1970: 1609545600)  // 2 Jan 2021 00:00:00 GMT
    let fixedUpdatedAt = Date(timeIntervalSince1970: 1609632000) // 3 Jan 2021 00:00:00 GMT
    
    override func setUpWithError() throws {}
    
    override func tearDownWithError() throws {}
    
    // Создание задачи с минимальным набором параметров
    func testTodoItemCreationWithMinimalParametrs() {
        let text = "Test Task"
        let importance = Importance.medium
        let isReady = false
        
        let sut = TodoItem(text: text, importance: importance, isReady: isReady, createdAt: fixedCreatedAt)
        
        XCTAssertEqual(sut.text, text)
        XCTAssertEqual(sut.importance, importance)
        XCTAssertEqual(sut.isReady, isReady)
        XCTAssertEqual(sut.createdAt, fixedCreatedAt)
        XCTAssertNil(sut.deadline)
        XCTAssertNil(sut.updatedAt)
        XCTAssertFalse(sut.id.isEmpty)
    }
    
    // Создание задачи с максимальным набором параметров
    func testTodoItemCreationWithMaximalParametrs() {
        let id = "custom_id"
        let text = "Test Task "
        let importance = Importance.low
        let isReady = true
        
        
        let sut = TodoItem(id: id, text: text, importance: importance, deadline: fixedDeadline, isReady: isReady, createdAt: fixedCreatedAt, updatedAt: fixedUpdatedAt)
        
        XCTAssertEqual(sut.id, id)
        XCTAssertEqual(sut.text, text)
        XCTAssertEqual(sut.importance, importance)
        XCTAssertEqual(sut.deadline, fixedDeadline)
        XCTAssertEqual(sut.isReady, isReady)
        XCTAssertEqual(sut.createdAt, fixedCreatedAt)
        XCTAssertEqual(sut.updatedAt, fixedUpdatedAt)
    }
    
    // Тестирование пустого текста
    func testTodoItemCreationWithEmptyText() {
        let text = ""
        let importance = Importance.medium
        let isReady = false

        let todoItem = TodoItem(text: text, importance: importance, isReady: isReady, createdAt: fixedCreatedAt)

        XCTAssertEqual(todoItem.text, text)
        XCTAssertEqual(todoItem.importance, importance)
        XCTAssertEqual(todoItem.isReady, isReady)
        XCTAssertEqual(todoItem.createdAt, fixedCreatedAt)
        XCTAssertNil(todoItem.deadline)
        XCTAssertNil(todoItem.updatedAt)
    }
    
    // Тестирование крайних значений дат
    func testTodoItemCreationWithExtremePastDates() {
        let pastDate = Date(timeIntervalSince1970: -1000000000) // Далекое прошлое

        let todoItem = TodoItem(text: "Past Task", importance: .low, deadline: pastDate, isReady: false, createdAt: pastDate)

        XCTAssertEqual(todoItem.deadline, pastDate)
        XCTAssertEqual(todoItem.createdAt, pastDate)
    }

    // Тестирование крайних значений дат
    func testTodoItemCreationWithExtremeFutureDates() {
        let futureDate = Date(timeIntervalSince1970: 32503680000) // Далекое будущее

        let todoItem = TodoItem(text: "Future Task", importance: .high, deadline: futureDate, isReady: false, createdAt: futureDate)

        XCTAssertEqual(todoItem.deadline, futureDate)
        XCTAssertEqual(todoItem.createdAt, futureDate)
    }

    // Тестирование всех значений Importance
    func testTodoItemWithLowImportance() {
        let todoItem = TodoItem(text: "Low Importance Task", importance: .low, isReady: false, createdAt: fixedCreatedAt)

        XCTAssertEqual(todoItem.importance, Importance.low)
    }
    
    // Тестирование всех значений Importance
    func testTodoItemWithMediumImportance() {
        let todoItem = TodoItem(text: "Medium Importance Task", importance: .medium, isReady: false, createdAt: fixedCreatedAt)

        XCTAssertEqual(todoItem.importance, Importance.medium)
    }

    // Тестирование всех значений Importance
    func testTodoItemWithHighImportance() {
        let todoItem = TodoItem(text: "High Importance Task", importance: .high, isReady: false, createdAt: fixedCreatedAt)

        XCTAssertEqual(todoItem.importance, Importance.high)
    }

    // Тестирование isReady
    func testTodoItemWithIsReadyTrue() {
        let todoItem = TodoItem(text: "Completed Task", importance: .medium, isReady: true, createdAt: fixedCreatedAt)

        XCTAssertTrue(todoItem.isReady)
    }
    
    // Тестирование isReady
    func testTodoItemWithIsReadyFalse() {
        let todoItem = TodoItem(text: "Incomplete Task", importance: .medium, isReady: false, createdAt: fixedCreatedAt)

        XCTAssertFalse(todoItem.isReady)
    }
    
    // Тестирование уникальности идентификаторов
    func testTodoItemUniqueID() {
        let todoItem1 = TodoItem(text: "Task 1", importance: .medium, isReady: false, createdAt: fixedCreatedAt)
        let todoItem2 = TodoItem(text: "Task 2", importance: .medium, isReady: false, createdAt: fixedCreatedAt)

        XCTAssertNotEqual(todoItem1.id, todoItem2.id)
    }
    
    

//        // Тест производительности сериализации объектов в JSON
//        func testPerformanceJsonSerialization() throws {
//            measure(
//                metrics: [
//                  XCTClockMetric(),
//                  XCTCPUMetric(),
//                  XCTStorageMetric(),
//                  XCTMemoryMetric()
//                ]
//              ) {
//
//              }
//        }

}
