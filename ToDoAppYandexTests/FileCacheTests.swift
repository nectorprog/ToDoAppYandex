import XCTest
@testable import ToDoAppYandex

final class FileCacheTests: XCTestCase {
    var fileCache: FileCache!
    let fixedCreatedAt = Date(timeIntervalSince1970: 1609459200) // 1 Jan 2021 00:00:00 GMT
    let fixedDeadline = Date(timeIntervalSince1970: 1609545600)  // 2 Jan 2021 00:00:00 GMT
    let fixedUpdatedAt = Date(timeIntervalSince1970: 1609632000) // 3 Jan 2021 00:00:00 GMT

    override func setUpWithError() throws {
        fileCache = FileCache()
    }

    override func tearDownWithError() throws {
        fileCache = nil
    }

    func testAddItem() {
        let item = TodoItem(id: "1", text: "Test Task", importance: .medium, deadline: fixedDeadline, isReady: false, createdAt: fixedCreatedAt, updatedAt: fixedUpdatedAt)
        fileCache.add(item: item)
        XCTAssertEqual(fileCache.allItems.count, 1)
        XCTAssertEqual(fileCache.allItems.first?.id, "1")
    }

    func testAddDuplicateItem() {
        let item1 = TodoItem(id: "1", text: "Test Task", importance: .medium, deadline: fixedDeadline, isReady: false, createdAt: fixedCreatedAt, updatedAt: fixedUpdatedAt)
        let item2 = TodoItem(id: "1", text: "Test Task Duplicate", importance: .high, deadline: fixedDeadline, isReady: true, createdAt: fixedCreatedAt, updatedAt: fixedUpdatedAt)
        fileCache.add(item: item1)
        fileCache.add(item: item2)
        XCTAssertEqual(fileCache.allItems.count, 1)
        XCTAssertEqual(fileCache.allItems.first?.text, "Test Task")
    }

    func testRemoveItem() {
        let item = TodoItem(id: "1", text: "Test Task", importance: .medium, deadline: fixedDeadline, isReady: false, createdAt: fixedCreatedAt, updatedAt: fixedUpdatedAt)
        fileCache.add(item: item)
        fileCache.remove(id: "1")
        XCTAssertEqual(fileCache.allItems.count, 0)
    }

    func testSaveAndLoadJSON() {
        let item1 = TodoItem(id: "1", text: "Test Task 1", importance: .medium, deadline: fixedDeadline, isReady: false, createdAt: fixedCreatedAt, updatedAt: fixedUpdatedAt)
        let item2 = TodoItem(id: "2", text: "Test Task 2", importance: .high, deadline: fixedDeadline, isReady: true, createdAt: fixedCreatedAt, updatedAt: fixedUpdatedAt)
        fileCache.add(item: item1)
        fileCache.add(item: item2)
        
        let fileName = "test.json"
        fileCache.save(fileName: fileName, format: "json")
        fileCache = FileCache()

        fileCache.load(from: fileName, format: "json")
        XCTAssertEqual(fileCache.allItems.count, 2)
        XCTAssertEqual(fileCache.allItems.first?.id, "1")
        XCTAssertEqual(fileCache.allItems.last?.id, "2")
    }

    
    func testSaveUnsupportedFormat() {
        let item = TodoItem(id: "1", text: "Test Task", importance: .medium, deadline: fixedDeadline, isReady: false, createdAt: fixedCreatedAt, updatedAt: fixedUpdatedAt)
        fileCache.add(item: item)
        
        let fileName = "test.unsupported"
        fileCache.save(fileName: fileName, format: "unsupported")
        
        let fileManager = FileManager.default
        let url = fileCache.getDocumentsDirectory().appendingPathComponent(fileName)
        XCTAssertFalse(fileManager.fileExists(atPath: url.path))
    }

    func testLoadUnsupportedFormat() {
        let fileName = "test.unsupported"
        fileCache.load(from: fileName, format: "unsupported")
        
        XCTAssertEqual(fileCache.allItems.count, 0)
    }
}
