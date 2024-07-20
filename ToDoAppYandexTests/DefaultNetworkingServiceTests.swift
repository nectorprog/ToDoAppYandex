//import XCTest
//@testable import ToDoAppYandex // Замените на имя вашего модуля
//
//class MockURLProtocol: URLProtocol {
//    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data?))?
//    
//    override class func canInit(with request: URLRequest) -> Bool {
//        return true
//    }
//    
//    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
//        return request
//    }
//    
//    override func startLoading() {
//        guard let handler = MockURLProtocol.requestHandler else {
//            XCTFail("Received unexpected request with no handler set")
//            return
//        }
//        do {
//            let (response, data) = try handler(request)
//            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
//            if let data = data {
//                client?.urlProtocol(self, didLoad: data)
//            }
//            client?.urlProtocolDidFinishLoading(self)
//        } catch {
//            client?.urlProtocol(self, didFailWithError: error)
//        }
//    }
//    
//    override func stopLoading() {}
//}
//
//class DefaultNetworkingServiceTests: XCTestCase {
//    var networkingService: DefaultNetworkingService!
//    var session: URLSession!
//    
//    override func setUp() {
//        super.setUp()
//        
//        let configuration = URLSessionConfiguration.ephemeral
//        configuration.protocolClasses = [MockURLProtocol.self]
//        session = URLSession(configuration: configuration)
//        
//        networkingService = DefaultNetworkingService()
//        networkingService.session = session
//    }
//    
//    override func tearDown() {
//        networkingService = nil
//        session = nil
//        MockURLProtocol.requestHandler = nil
//        super.tearDown()
//    }
//    
//    func testGetItems() {
//        let expectation = self.expectation(description: "Get items")
//        
//        let mockItems = [
//            ["id": "1", "text": "Test 1", "importance": "low", "done": false, "created_at": 1625097600, "changed_at": 1625097600],
//            ["id": "2", "text": "Test 2", "importance": "important", "done": true, "created_at": 1625184000, "changed_at": 1625184000]
//        ]
//        
//        let mockResponse = ["list": mockItems, "revision": 1]
//        let mockData = try! JSONSerialization.data(withJSONObject: mockResponse, options: [])
//        
//        MockURLProtocol.requestHandler = { request in
//            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
//            return (response, mockData)
//        }
//        
//        networkingService.getItems { result in
//            switch result {
//            case .success(let items):
//                XCTAssertEqual(items.count, 2)
//                XCTAssertEqual(items[0].id, "1")
//                XCTAssertEqual(items[1].id, "2")
//            case .failure(let error):
//                XCTFail("Expected success, got \(error) instead")
//            }
//            expectation.fulfill()
//        }
//        
//        waitForExpectations(timeout: 1, handler: nil)
//    }
//    
//    func testAddItem() {
//        let expectation = self.expectation(description: "Add item")
//        
//        let newItem = TodoItem(id: "3", text: "New Item", importance: .medium, isReady: false, createdAt: Date())
//        
//        let mockResponse = [
//            "element": [
//                "id": "3",
//                "text": "New Item",
//                "importance": "basic",
//                "done": false,
//                "created_at": Int(newItem.createdAt.timeIntervalSince1970),
//                "changed_at": Int(newItem.createdAt.timeIntervalSince1970)
//            ],
//            "revision": 2
//        ]
//        let mockData = try! JSONSerialization.data(withJSONObject: mockResponse, options: [])
//        
//        MockURLProtocol.requestHandler = { request in
//            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
//            return (response, mockData)
//        }
//        
//        networkingService.addItem(newItem) { result in
//            switch result {
//            case .success(let item):
//                XCTAssertEqual(item.id, "3")
//                XCTAssertEqual(item.text, "New Item")
//            case .failure(let error):
//                XCTFail("Expected success, got \(error) instead")
//            }
//            expectation.fulfill()
//        }
//        
//        waitForExpectations(timeout: 1, handler: nil)
//    }
//    
//    func testUpdateItem() {
//        let expectation = self.expectation(description: "Update item")
//        
//        let updatedItem = TodoItem(id: "1", text: "Updated Item", importance: .high, isReady: true, createdAt: Date())
//        
//        let mockResponse = [
//            "element": [
//                "id": "1",
//                "text": "Updated Item",
//                "importance": "important",
//                "done": true,
//                "created_at": Int(updatedItem.createdAt.timeIntervalSince1970),
//                "changed_at": Int(updatedItem.createdAt.timeIntervalSince1970)
//            ],
//            "revision": 3
//        ]
//        let mockData = try! JSONSerialization.data(withJSONObject: mockResponse, options: [])
//        
//        MockURLProtocol.requestHandler = { request in
//            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
//            return (response, mockData)
//        }
//        
//        networkingService.updateItem(updatedItem) { result in
//            switch result {
//            case .success(let item):
//                XCTAssertEqual(item.id, "1")
//                XCTAssertEqual(item.text, "Updated Item")
//                XCTAssertEqual(item.importance, .high)
//                XCTAssertTrue(item.isReady)
//            case .failure(let error):
//                XCTFail("Expected success, got \(error) instead")
//            }
//            expectation.fulfill()
//        }
//        
//        waitForExpectations(timeout: 1, handler: nil)
//    }
//    
//    func testDeleteItem() {
//        let expectation = self.expectation(description: "Delete item")
//        
//        let mockResponse = ["revision": 4]
//        let mockData = try! JSONSerialization.data(withJSONObject: mockResponse, options: [])
//        
//        MockURLProtocol.requestHandler = { request in
//            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
//            return (response, mockData)
//        }
//        
//        networkingService.deleteItem("1") { result in
//            switch result {
//            case .success:
//                // Success case is empty, we just need to make sure it doesn't fail
//                break
//            case .failure(let error):
//                XCTFail("Expected success, got \(error) instead")
//            }
//            expectation.fulfill()
//        }
//        
//        waitForExpectations(timeout: 1, handler: nil)
//    }
//    
//    func testPatchList() {
//        let expectation = self.expectation(description: "Patch list")
//        
//        let items = [
//            TodoItem(id: "1", text: "Item 1", importance: .low, isReady: false, createdAt: Date()),
//            TodoItem(id: "2", text: "Item 2", importance: .medium, isReady: true, createdAt: Date())
//        ]
//        
//        let mockResponse = [
//            "list": [
//                ["id": "1", "text": "Item 1", "importance": "low", "done": false, "created_at": Int(items[0].createdAt.timeIntervalSince1970), "changed_at": Int(items[0].createdAt.timeIntervalSince1970)],
//                ["id": "2", "text": "Item 2", "importance": "basic", "done": true, "created_at": Int(items[1].createdAt.timeIntervalSince1970), "changed_at": Int(items[1].createdAt.timeIntervalSince1970)]
//            ],
//            "revision": 5
//        ]
//        let mockData = try! JSONSerialization.data(withJSONObject: mockResponse, options: [])
//        
//        MockURLProtocol.requestHandler = { request in
//            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
//            return (response, mockData)
//        }
//        
//        networkingService.patchList(items) { result in
//            switch result {
//            case .success(let patchedItems):
//                XCTAssertEqual(patchedItems.count, 2)
//                XCTAssertEqual(patchedItems[0].id, "1")
//                XCTAssertEqual(patchedItems[1].id, "2")
//            case .failure(let error):
//                XCTFail("Expected success, got \(error) instead")
//            }
//            expectation.fulfill()
//        }
//        
//        waitForExpectations(timeout: 1, handler: nil)
//    }
//}
