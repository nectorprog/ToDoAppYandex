import XCTest
@testable import ToDoAppYandex

class URLSessionExtensionTests: XCTestCase {
    
    func testDataTaskForURLRequest() {
        let expectation = XCTestExpectation(description: "API call")
        
        let url = URL(string: "https://jsonplaceholder.typicode.com/todos/1")!
        let urlRequest = URLRequest(url: url)
        
        DispatchQueue.global().async {
            do {
                let (data, response) = try URLSession.shared.dataTask(for: urlRequest)
                XCTAssertNotNil(data)
                XCTAssertNotNil(response)
                XCTAssertTrue(response is HTTPURLResponse)
                
                // Проверяем, что получили валидный JSON
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                XCTAssertNotNil(json)
                XCTAssertEqual(json?["id"] as? Int, 1)
                XCTAssertEqual(json?["title"] as? String, "delectus aut autem")
                
                expectation.fulfill()
            } catch {
                XCTFail("Error: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testDataTaskForInvalidURL() {
        let expectation = XCTestExpectation(description: "Invalid URL call")
        
        let url = URL(string: "https://jsonplaceholder.typicode.com/invalid")!
        let urlRequest = URLRequest(url: url)
        
        DispatchQueue.global().async {
            do {
                let (_, response) = try URLSession.shared.dataTask(for: urlRequest)
                XCTAssertTrue(response is HTTPURLResponse)
                let httpResponse = response as! HTTPURLResponse
                XCTAssertEqual(httpResponse.statusCode, 404)
                expectation.fulfill()
            } catch {
                XCTFail("Error: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testConcurrentRequests() {
        let expectation = XCTestExpectation(description: "Concurrent requests")
        expectation.expectedFulfillmentCount = 10
        
        let url = URL(string: "https://jsonplaceholder.typicode.com/todos/1")!
        let urlRequest = URLRequest(url: url)
        
        DispatchQueue.concurrentPerform(iterations: 10) { _ in
            do {
                let (data, response) = try URLSession.shared.dataTask(for: urlRequest)
                XCTAssertNotNil(data)
                XCTAssertNotNil(response)
                expectation.fulfill()
            } catch {
                XCTFail("Error: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 30.0)
    }
    
    func testConcurrentRequestsWithDifferentURLs() {
        let expectation = XCTestExpectation(description: "Concurrent requests with different URLs")
        expectation.expectedFulfillmentCount = 5
        
        let urls = [
            "https://jsonplaceholder.typicode.com/todos/1",
            "https://jsonplaceholder.typicode.com/todos/2",
            "https://jsonplaceholder.typicode.com/todos/3",
            "https://jsonplaceholder.typicode.com/todos/4",
            "https://jsonplaceholder.typicode.com/todos/5"
        ]
        
        DispatchQueue.concurrentPerform(iterations: 5) { index in
            let url = URL(string: urls[index])!
            let urlRequest = URLRequest(url: url)
            do {
                let (data, response) = try URLSession.shared.dataTask(for: urlRequest)
                XCTAssertNotNil(data)
                XCTAssertNotNil(response)
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                XCTAssertEqual(json?["id"] as? Int, index + 1)
                expectation.fulfill()
            } catch {
                XCTFail("Error: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 30.0)
    }
}
