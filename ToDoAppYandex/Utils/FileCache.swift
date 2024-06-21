import Foundation

class FileCache {
    private var items: [TodoItem] = []
    
    var allItems: [TodoItem] {
        return items
    }
    
    func add(item: TodoItem) {
        if !items.contains(where: {$0.id == item.id}) {
            items.append(item)
        }
    }
    
    func remove(id: String) {
        items.removeAll{$0.id == id}
    }
    
    private func getDocumentsDirectory() -> URL {
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            return paths[0]
    }
    
    func save(fileName: String) {
        let itemsArray = items.map({ item -> [String: Any] in
            var dict = ["id": item.id, "text": item.text, "isReady": item.isReady]
            
            if item.importance != .medium {
                dict["importance"] = item.importance.rawValue
            }
            if let deadline = item.deadline {
                dict["deadline"] = ISO8601DateFormatter().string(from: deadline)
            }
            dict["createdAt"] = ISO8601DateFormatter().string(from: item.createdAt)
            if let updatedAt = item.updatedAt {
                dict["updatedAt"] = ISO8601DateFormatter().string(from: updatedAt)
            }
            return dict
        })
        
        do {
                let jsonData = try JSONSerialization.data(withJSONObject: itemsArray, options: [])
                let url = getDocumentsDirectory().appendingPathComponent(fileName)
                try jsonData.write(to: url)
            } catch {
                print("Failed to save data: \(error)")
            }
    }
    
    func load(from fileName: String) {
        let url = getDocumentsDirectory().appendingPathComponent(fileName)
        do {
                let jsonData = try Data(contentsOf: url)
                let jsonArray = try JSONSerialization.jsonObject(with: jsonData) as? [[String: Any]] ?? []
                items = jsonArray.compactMap { dict in
                    guard let id = dict["id"] as? String,
                          let text = dict["text"] as? String,
                          let isReady = dict["isReady"] as? Bool,
                          let createdAtString = dict["createdAt"] as? String,
                          let createdAt = ISO8601DateFormatter().date(from: createdAtString) else {
                        return nil
                    }
                    let updatedAtString = dict["updatedAt"] as? String
                    let updatedAt = updatedAtString.flatMap { ISO8601DateFormatter().date(from: $0) }
                    let importanceRaw = dict["importance"] as? String
                    let importance = Importance(rawValue: importanceRaw ?? "") ?? .medium
                    let deadlineString = dict["deadline"] as? String
                    let deadline = deadlineString.flatMap { ISO8601DateFormatter().date(from: $0) }
                    return TodoItem(id: id, text: text, importance: importance, deadline: deadline, isReady: isReady, createdAt: createdAt, updatedAt: updatedAt)
                }
            } catch {
                print("Error loading data: \(error)")
        }
    }
}
