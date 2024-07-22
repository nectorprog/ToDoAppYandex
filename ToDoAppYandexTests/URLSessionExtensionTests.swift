import XCTest
@testable import ToDoAppYandex

class URLSessionExtensionTests: XCTestCase {
    
    func testSuccessfulRequest() async throws {
        // Проверка успешного запроса
        let url = URL(string: "https://jsonplaceholder.typicode.com/todos/1")!
        let request = URLRequest(url: url)
        
        let (data, response) = try await URLSession.shared.dataTask(for: request)
        
        XCTAssertFalse(data.isEmpty, "Данные не должны быть пустыми")
        XCTAssertTrue(response is HTTPURLResponse, "Ответ должен быть HTTPURLResponse")
        if let httpResponse = response as? HTTPURLResponse {
            XCTAssertEqual(httpResponse.statusCode, 200, "Статус код должен быть 200")
        }
    }
    
    func testCancellation() async {
        // Проверка отмены запроса
        let url = URL(string: "https://jsonplaceholder.typicode.com/users")!
        let request = URLRequest(url: url)
        
        let task = Task {
            do {
                _ = try await URLSession.shared.dataTask(for: request)
                XCTFail("Ожидалась ошибка отмены")
            } catch let error as URLError where error.code == .cancelled {
                XCTAssertEqual(error.code, .cancelled, "Ожидалась ошибка отмены")
            } catch {
                XCTFail("Неожиданная ошибка: \(error)")
            }
        }
        
        task.cancel()
        
        await task.value
    }
    
    func testTimeout() async {
        // Проверка таймаута запроса
        let url = URL(string: "https://jsonplaceholder.typicode.com/comments")!
        var request = URLRequest(url: url)
        request.timeoutInterval = 0.001 // Устанавливаем очень короткий таймаут
        
        do {
            _ = try await URLSession.shared.dataTask(for: request)
            XCTFail("Ожидалась ошибка таймаута")
        } catch let error as URLError where error.code == .timedOut {
            XCTAssertEqual(error.code, .timedOut, "Ожидалась ошибка таймаута")
        } catch {
            XCTFail("Неожиданная ошибка: \(error)")
        }
    }
}
