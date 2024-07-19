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
    private let baseURL = "https://beta.mrdekk.ru/todobackend"
    private let token = "Adaneth"
    private var lastKnownRevision: Int = 0
    
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
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    if let revision = json?["revision"] as? Int {
                        self?.lastKnownRevision = revision
                    }
                    if let list = json?["list"] as? [[String: Any]] {
                        let items = list.compactMap { TodoItem.parse(json: $0) }
                        completion(.success(items))
                    } else {
                        completion(.failure(.decodingError))
                    }
                } catch {
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
        let request = makeRequest(path: path, method: "PUT", body: body)
        
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
                       let updatedItem = TodoItem.parse(json: element) {
                        self?.lastKnownRevision = revision
                        completion(.success(updatedItem))
                    } else {
                        completion(.failure(.decodingError))
                    }
                } catch {
                    completion(.failure(.decodingError))
                }
            }
        }.resume()
    }

    func deleteItem(_ id: String, completion: @escaping (Result<Void, NetworkError>) -> Void) {
        let path = "/list/\(id)"
        let request = makeRequest(path: path, method: "DELETE")
        
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
                
                if let data = data,
                   let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let revision = json["revision"] as? Int {
                    self?.lastKnownRevision = revision
                }
                
                completion(.success(()))
            }
        }.resume()
    }

    func patchList(_ items: [TodoItem], completion: @escaping (Result<[TodoItem], NetworkError>) -> Void) {
        let path = "/list"
        let body = try? JSONSerialization.data(withJSONObject: ["list": items.map { $0.dict }])
        let request = makeRequest(path: path, method: "PATCH", body: body)
        
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
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    if let revision = json?["revision"] as? Int {
                        self?.lastKnownRevision = revision
                    }
                    if let list = json?["list"] as? [[String: Any]] {
                        let items = list.compactMap { TodoItem.parse(json: $0) }
                        completion(.success(items))
                    } else {
                        completion(.failure(.decodingError))
                    }
                } catch {
                    completion(.failure(.decodingError))
                }
            }
        }.resume()
    }
}
