import Foundation

extension URLSession {
    func dataTask(for urlRequest: URLRequest) throws -> (Data, URLResponse) {
        let semaphore = DispatchSemaphore(value: 0)
        let resultQueue = DispatchQueue(label: "com.urlsession.result", attributes: .concurrent)
        var resultData: Data?
        var resultResponse: URLResponse?
        var resultError: Error?

        let task = self.dataTask(with: urlRequest) { data, response, error in
            resultQueue.async(flags: .barrier) {
                resultData = data
                resultResponse = response
                resultError = error
            }
            semaphore.signal()
        }

        task.resume()

        // Ожидаем завершения задачи или возникновения ошибки
        if semaphore.wait(timeout: .now() + 30) == .timedOut {
            task.cancel()
            throw NSError(domain: NSURLErrorDomain, code: NSURLErrorTimedOut, userInfo: nil)
        }

        return try resultQueue.sync {
            if let error = resultError {
                throw error
            }
            guard let data = resultData, let response = resultResponse else {
                throw NSError(domain: "URLSessionError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data or response"])
            }
            return (data, response)
        }
    }
}
