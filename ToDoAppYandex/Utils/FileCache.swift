import Foundation

class FileCache {
    private var items: [TodoItem] = []
    
    var allItems: [TodoItem] {
        return items
    }
    
    func add(item: TodoItem) {
        if !items.contains(where: { $0.id == item.id }) {
            items.append(item)
        }
    }
    
    func remove(id: String) {
        items.removeAll { $0.id == id }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func save(fileName: String, format: String) {
        let url = getDocumentsDirectory().appendingPathComponent(fileName)
        if format.lowercased() == "json" {
            saveToJSON(url: url)
        } else if format.lowercased() == "csv" {
            saveToCSV(url: url)
        } else {
            print("Unsupported file format")
        }
    }
    
    private func saveToJSON(url: URL) {
            let itemsArray = items.map { item -> [String: Any] in
                var dict: [String: Any] = ["id": item.id, "text": item.text, "isReady": item.isReady, "createdAt": item.createdAt.unixTimestamp]
                if item.importance != .medium {
                    dict["importance"] = item.importance.rawValue
                }
                if let deadline = item.deadline {
                    dict["deadline"] = deadline.unixTimestamp
                }
                if let updatedAt = item.updatedAt {
                    dict["updatedAt"] = updatedAt.unixTimestamp
                }
                return dict
            }
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: itemsArray, options: [])
                try jsonData.write(to: url)
                print("Data saved successfully to \(url).")
            } catch {
                print("Failed to save data: \(error)")
            }
        }
    
//    private func saveToCSV(url: URL) {
//        let headers = "id,text,importance,isReady,createdAt,deadline,updatedAt\n"
//        let csvData = items.map { $0.toCSV.split(separator: "\n").last! }.joined(separator: "\n")
//        let data = headers + csvData
//        do {
//            try data.write(to: url, atomically: true, encoding: .utf8)
//            print("Data saved successfully to \(url).")
//        } catch {
//            print("Failed to save data: \(error)")
//        }
//    }
    
    private func saveToCSV(url: URL) {
        let headers = "id,text,importance,isReady,createdAt,deadline,updatedAt\n"
        let csvData = items.map { $0.toCSV.split(separator: "\n").last! }.joined(separator: "\n")
        let data = headers + csvData
        print("Saving CSV Data: \n\(data)")
        do {
            try data.write(to: url, atomically: true, encoding: .utf8)
            print("Data saved successfully to \(url).")
        } catch {
            print("Failed to save data: \(error)")
        }
    }
    
    func load(from fileName: String, format: String) {
        let url = getDocumentsDirectory().appendingPathComponent(fileName)
        if format.lowercased() == "json" {
            loadFromJSON(url: url)
        } else if format.lowercased() == "csv" {
            loadFromCSV(url: url)
        } else {
            print("Unsupported file format")
        }
    }
    
    private func loadFromJSON(url: URL) {
        do {
            let jsonData = try Data(contentsOf: url)
            let jsonArray = try JSONSerialization.jsonObject(with: jsonData) as? [[String: Any]] ?? []
            items = jsonArray.compactMap { dict in
                guard let jsonString = try? JSONSerialization.data(withJSONObject: dict, options: []),
                      let json = String(data: jsonString, encoding: .utf8) else {
                    return nil
                }
                return TodoItem.parse(json: json)
            }
            print("Data loaded successfully from \(url).")
        } catch {
            print("Error loading data: \(error)")
        }
    }
    
//    private func loadFromCSV(url: URL) {
//        do {
//            let data = try String(contentsOf: url, encoding: .utf8)
//            let rows = data.split(separator: "\n")
//            let itemsArray = rows.dropFirst().compactMap { TodoItem.parse(csv: String($0)) }
//            items = itemsArray
//            print("Data loaded successfully from \(url).")
//        } catch {
//            print("Error loading data: \(error)")
//        }
//    }
    
    private func loadFromCSV(url: URL) {
        do {
            let data = try String(contentsOf: url, encoding: .utf8)
            print("Loaded CSV Data: \n\(data)")
            let rows = data.split(separator: "\n")
            let itemsArray = rows.dropFirst().compactMap { TodoItem.parse(csv: String($0)) }
            items = itemsArray
            print("Data loaded successfully from \(url).")
        } catch {
            print("Error loading data: \(error)")
        }
    }
}




