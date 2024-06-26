import XCTest
@testable import ToDoAppYandex

class FileCacheTests: XCTestCase {
    var fileCache: FileCache!
    let testFilename = "testFile"
    
    override func setUp() {
        super.setUp()
        fileCache = FileCache()
    }
    
    override func tearDown() {
        super.tearDown()
        removeTestFiles()
        fileCache = nil
    }
    
    func testAddItem() {
        let item = TodoItem(text: "Test Task", importance: .medium, createdAt: Date())
        fileCache.add(item)
        
        XCTAssertEqual(fileCache.items.count, 1)
        XCTAssertEqual(fileCache.items.first, item)
    }
    
    func testRemoveItem() {
        let item = TodoItem(text: "Test Task", importance: .medium, createdAt: Date())
        fileCache.add(item)
        let removedItem = fileCache.remove(id: item.id)
        
        XCTAssertEqual(fileCache.items.count, 0)
        XCTAssertEqual(removedItem, item)
    }
    
    func testSaveAndLoadJSON() {
            let item1 = TodoItem(text: "Task 1", importance: .medium, createdAt: Date())
            let item2 = TodoItem(text: "Task 2", importance: .high, createdAt: Date())
            fileCache.add(item1)
            fileCache.add(item2)
            
            fileCache.saveToJSON(filename: testFilename)
            
            let newFileCache = FileCache()
            newFileCache.loadFromJSON(filename: testFilename)
            
            XCTAssertEqual(newFileCache.items.count, 2)
            XCTAssertEqual(newFileCache.items[0], item1)
            XCTAssertEqual(newFileCache.items[1], item2)
        }
        
        func testSaveAndLoadCSV() {
            let item1 = TodoItem(text: "Task 1", importance: .medium, createdAt: Date())
            let item2 = TodoItem(text: "Task 2", importance: .high, createdAt: Date())
            fileCache.add(item1)
            fileCache.add(item2)
            
            fileCache.saveToCSV(filename: testFilename)
            
            let newFileCache = FileCache()
            newFileCache.loadFromCSV(filename: testFilename)
            
            XCTAssertEqual(newFileCache.items.count, 2)
            XCTAssertEqual(newFileCache.items[0], item1)
            XCTAssertEqual(newFileCache.items[1], item2)
        }
    
    private func removeTestFiles() {
        let fileManager = FileManager.default
        let jsonURL = getDocumentsDirectory().appendingPathComponent("\(testFilename).json")
        let csvURL = getDocumentsDirectory().appendingPathComponent("\(testFilename).csv")
        
        try? fileManager.removeItem(at: jsonURL)
        try? fileManager.removeItem(at: csvURL)
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
