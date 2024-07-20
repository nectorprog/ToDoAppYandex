import Foundation

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case httpError(Int)
    case unknown
}

protocol NetworkingService {
    func getItems(completion: @escaping (Result<[TodoItem], NetworkError>) -> Void)
    func addItem(_ item: TodoItem, completion: @escaping (Result<TodoItem, NetworkError>) -> Void)
    func updateItem(_ item: TodoItem, completion: @escaping (Result<TodoItem, NetworkError>) -> Void)
    func deleteItem(_ id: String, completion: @escaping (Result<Void, NetworkError>) -> Void)
    func patchList(_ items: [TodoItem], completion: @escaping (Result<[TodoItem], NetworkError>) -> Void)
}

class DefaultNetworkingService: NetworkingService {
    private let baseURL = "https://beta.mrdekk.ru/todo"
    private let token = "Adaneth"
    private var lastKnownRevision: Int = 0
    private let session: URLSession
        
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 30
        
        let delegate = NetworkDelegate()
        self.session = URLSession(configuration: configuration, delegate: delegate, delegateQueue: nil)
    }
    
    private func makeRequest(path: String, method: String, body: Data? = nil) -> URLRequest {
        var request = URLRequest(url: URL(string: baseURL + path)!)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("\(lastKnownRevision)", forHTTPHeaderField: "X-Last-Known-Revision")
        request.httpBody = body
        return request
    }
    
    func getItems(completion: @escaping (Result<[TodoItem], NetworkError>) -> Void) {
        let request = makeRequest(path: "/list", method: "GET")
        
        print("Sending request to: \(request.url?.absoluteString ?? "Unknown URL")")
        print("Headers: \(request.allHTTPHeaderFields ?? [:])")

        session.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("Network error: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(.unknown))
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response type")
                DispatchQueue.main.async {
                    completion(.failure(.unknown))
                }
                return
            }

            print("Response status code: \(httpResponse.statusCode)")
            print("Response headers: \(httpResponse.allHeaderFields)")

            guard (200...299).contains(httpResponse.statusCode) else {
                print("HTTP error: \(httpResponse.statusCode)")
                DispatchQueue.main.async {
                    completion(.failure(.httpError(httpResponse.statusCode)))
                }
                return
            }

            guard let data = data else {
                print("No data received")
                DispatchQueue.main.async {
                    completion(.failure(.noData))
                }
                return
            }

            do {
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Response data: \(responseString)")
                }

                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                if let revision = json?["revision"] as? Int {
                    self?.lastKnownRevision = revision
                }
                if let list = json?["list"] as? [[String: Any]] {
                    let items = list.compactMap { TodoItem.parse(json: $0) }
                    print("Parsed \(items.count) items")
                    DispatchQueue.main.async {
                        completion(.success(items))
                    }
                } else {
                    print("Invalid JSON structure")
                    DispatchQueue.main.async {
                        completion(.failure(.decodingError))
                    }
                }
            } catch {
                print("JSON parsing error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(.decodingError))
                }
            }
        }.resume()
    }
    
    func addItem(_ item: TodoItem, completion: @escaping (Result<TodoItem, NetworkError>) -> Void) {
        let path = "/list"
        let element = [
            "id": item.id,
            "text": item.text,
            "importance": item.importance.rawValue,
            "deadline": item.deadline?.timeIntervalSince1970 ?? 0,
            "done": item.isReady,
            "color": item.color,
            "created_at": item.createdAt.timeIntervalSince1970,
            "changed_at": item.updatedAt?.timeIntervalSince1970 ?? item.createdAt.timeIntervalSince1970,
            "last_updated_by": "device_id"
        ] as [String : Any]
        let body = try? JSONSerialization.data(withJSONObject: ["element": element])
        let request = makeRequest(path: path, method: "POST", body: body)
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.global().async {
                if let error = error {
                    completion(.failure(.unknown))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(.unknown))
                    return
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    completion(.failure(.httpError(httpResponse.statusCode)))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(.noData))
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let revision = json["revision"] as? Int,
                       let element = json["element"] as? [String: Any],
                       let newItem = TodoItem.parse(json: element) {
                        self?.lastKnownRevision = revision
                        completion(.success(newItem))
                    } else {
                        completion(.failure(.decodingError))
                    }
                } catch {
                    completion(.failure(.decodingError))
                }
            }
        }.resume()
    }
    
    func updateItem(_ item: TodoItem, completion: @escaping (Result<TodoItem, NetworkError>) -> Void) {
        let path = "/list/\(item.id)"
        var element: [String: Any] = [
            "id": item.id,
            "text": item.text,
            "importance": convertImportance(item.importance),
            "done": item.isReady,
            "created_at": Int(item.createdAt.timeIntervalSince1970),
            "changed_at": Int(Date().timeIntervalSince1970),
            "last_updated_by": item.lastUpdatedBy
        ]
        
        if let deadline = item.deadline {
            element["deadline"] = Int(deadline.timeIntervalSince1970)
        }
        
        if !item.color.isEmpty {
            element["color"] = item.color
        }
        
        let body: Data
        do {
            body = try JSONSerialization.data(withJSONObject: ["element": element])
        } catch {
            print("Error serializing item: \(error)")
            DispatchQueue.main.async {
                completion(.failure(.unknown))
            }
            return
        }
        
        var request = makeRequest(path: path, method: "PUT", body: body)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        print("Updating item with ID \(item.id). Request body: \(String(data: body, encoding: .utf8) ?? "")")
        
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.global().async {
                if let error = error {
                    print("Network error: \(error)")
                    DispatchQueue.main.async {
                        completion(.failure(.unknown))
                    }
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Invalid response type")
                    DispatchQueue.main.async {
                        completion(.failure(.unknown))
                    }
                    return
                }
                
                print("Response status code: \(httpResponse.statusCode)")
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    print("HTTP error: \(httpResponse.statusCode)")
                    DispatchQueue.main.async {
                        completion(.failure(.httpError(httpResponse.statusCode)))
                    }
                    return
                }
                
                guard let data = data else {
                    print("No data received")
                    DispatchQueue.main.async {
                        completion(.failure(.noData))
                    }
                    return
                }
                
                do {
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("Response data: \(responseString)")
                    }
                    
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    if let revision = json?["revision"] as? Int {
                        self?.lastKnownRevision = revision
                    }
                    if let element = json?["element"] as? [String: Any],
                       let updatedItem = TodoItem.parse(json: element) {
                        DispatchQueue.main.async {
                            completion(.success(updatedItem))
                        }
                    } else {
                        print("Invalid JSON structure")
                        DispatchQueue.main.async {
                            completion(.failure(.decodingError))
                        }
                    }
                } catch {
                    print("JSON parsing error: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        completion(.failure(.decodingError))
                    }
                }
            }
        }
        
        task.resume()
    }
    
    func deleteItem(_ id: String, completion: @escaping (Result<Void, NetworkError>) -> Void) {
        let path = "/list/\(id)"
        let request = makeRequest(path: path, method: "DELETE")
        
        let task = session.dataTask(with: request) { data, response, error in
            DispatchQueue.global().async {
                if let error = error {
                    print("Network error: \(error)")
                    DispatchQueue.main.async {
                        completion(.failure(.unknown))
                    }
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Invalid response type")
                    DispatchQueue.main.async {
                        completion(.failure(.unknown))
                    }
                    return
                }
                
                print("Response status code: \(httpResponse.statusCode)")
                
                if (200...299).contains(httpResponse.statusCode) {
                    if let data = data,
                       let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let revision = json["revision"] as? Int {
                        self.lastKnownRevision = revision
                    }
                    DispatchQueue.main.async {
                        completion(.success(()))
                    }
                } else {
                    print("HTTP error: \(httpResponse.statusCode)")
                    DispatchQueue.main.async {
                        completion(.failure(.httpError(httpResponse.statusCode)))
                    }
                }
            }
        }
        
        task.resume()
    }

    func patchList(_ items: [TodoItem], completion: @escaping (Result<[TodoItem], NetworkError>) -> Void) {
        let path = "/list"
        let itemsJson = items.map { item -> [String: Any] in
            var json: [String: Any] = [
                "id": item.id,
                "text": item.text,
                "importance": item.importance.rawValue,
                "done": item.isReady,
                "color": item.color,
                "created_at": item.createdAt.timeIntervalSince1970,
                "changed_at": item.updatedAt?.timeIntervalSince1970 ?? item.createdAt.timeIntervalSince1970,
                "last_updated_by": item.lastUpdatedBy
            ]
            if let deadline = item.deadline {
                json["deadline"] = deadline.timeIntervalSince1970
            }
            return json
        }
        
        let body: Data
        do {
            body = try JSONSerialization.data(withJSONObject: ["list": itemsJson])
        } catch {
            print("Error serializing items: \(error)")
            DispatchQueue.main.async {
                completion(.failure(.unknown))
            }
            return
        }
        
        let request = makeRequest(path: path, method: "PATCH", body: body)
        
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.global().async {
                if let error = error {
                    print("Network error: \(error)")
                    DispatchQueue.main.async {
                        completion(.failure(.unknown))
                    }
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Invalid response type")
                    DispatchQueue.main.async {
                        completion(.failure(.unknown))
                    }
                    return
                }
                
                print("Response status code: \(httpResponse.statusCode)")
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    print("HTTP error: \(httpResponse.statusCode)")
                    DispatchQueue.main.async {
                        completion(.failure(.httpError(httpResponse.statusCode)))
                    }
                    return
                }
                
                guard let data = data else {
                    print("No data received")
                    DispatchQueue.main.async {
                        completion(.failure(.noData))
                    }
                    return
                }
                
                do {
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("Response data: \(responseString)")
                    }
                    
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    if let revision = json?["revision"] as? Int {
                        self?.lastKnownRevision = revision
                    }
                    if let list = json?["list"] as? [[String: Any]] {
                        let updatedItems = list.compactMap { TodoItem.parse(json: $0) }
                        DispatchQueue.main.async {
                            completion(.success(updatedItems))
                        }
                    } else {
                        print("Invalid JSON structure")
                        DispatchQueue.main.async {
                            completion(.failure(.decodingError))
                        }
                    }
                } catch {
                    print("JSON parsing error: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        completion(.failure(.decodingError))
                    }
                }
            }
        }
        
        task.resume()
    }
}

class NetworkDelegate: NSObject, URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            if let serverTrust = challenge.protectionSpace.serverTrust {
                let credential = URLCredential(trust: serverTrust)
                completionHandler(.useCredential, credential)
            }
        }
    }
}

private func convertImportance(_ importance: Importance) -> String {
    switch importance {
    case .low:
        return "low"
    case .medium:
        return "basic"
    case .high:
        return "important"
    }
}
