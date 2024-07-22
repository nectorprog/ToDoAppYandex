import Foundation
import CocoaLumberjackSwift

actor CancellationManager {
    var task: URLSessionDataTask?
    var isActive = true
    
    func terminate() {
        isActive = false
        task?.cancel()
    }
    
    func assignTask(_ dataTask: URLSessionDataTask) {
        task = dataTask
    }
}

extension URLSession {
    func dataTask(for urlRequest: URLRequest) async throws -> (Data, URLResponse) {
        let manager = CancellationManager()
        
        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                Task {
                    let task = self.dataTask(with: urlRequest) { data, response, error in
                        if let error = error {
                            continuation.resume(throwing: error)
                        } else if let data = data, let response = response {
                            DDLogInfo("Запрос успешно выполнен, возвращаем данные")
                            continuation.resume(returning: (data, response))
                        } else {
                            continuation.resume(throwing: URLError(.unknown))
                        }
                    }
                    await manager.assignTask(task)
                    if await manager.isActive {
                        task.resume()
                    } else {
                        DDLogWarn("Запрос был отменен, выбрасываем ошибку")
                        continuation.resume(throwing: URLError(.cancelled))
                    }
                }
            }
        } onCancel: {
            Task {
                await manager.terminate()
            }
        }
    }
}
