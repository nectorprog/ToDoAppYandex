import Foundation

class FileCache {
    private(set) var items: [TodoItem] = []
    
    func add(_ item: TodoItem) {
        if !items.contains(where: { $0.id == item.id }) {
            items.append(item)
        }
    }
    
    func remove(id: String) -> TodoItem? {
        if let index = items.firstIndex(where: { $0.id == id }) {
            return items.remove(at: index)
        }
        return nil
    }
    
    func saveToJSON(filename: String) {
        guard let data = serialize(items: items) else {
            print("Failed to serialize items.")
            return
        }
        
        let url = getDocumentsDirectory().appendingPathComponent("\(filename).json")
        
        do {
            try data.write(to: url, options: [.atomic])
        } catch {
            print("Error saving to file: \(error)")
        }
    }
    
    func loadFromJSON(filename: String) {
        let url = getDocumentsDirectory().appendingPathComponent("\(filename).json")
        do {
            let data = try Data(contentsOf: url)
            if let dictArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                self.items = dictArray.compactMap{TodoItem.from(dict: $0)}
            }
        } catch {
            print("Error loading from file: \(error)")
        }
    }
    
    func saveToCSV(filename: String) {
        guard !items.isEmpty else {
            print("No items to save.")
            return
        }
        
        var csvString = items.first!.csv.split(separator: "\n").first! + "\n"
        csvString += items.map { $0.csv.split(separator: "\n")[1] }.joined(separator: "\n")
        
        let url = getDocumentsDirectory().appendingPathComponent("\(filename).csv")
        
        do {
            try csvString.write(to: url, atomically: true, encoding: .utf8)
        } catch {
            print("Error saving to file: \(error)")
        }
    }

    func loadFromCSV(filename: String) {
        let url = getDocumentsDirectory().appendingPathComponent("\(filename).csv")
        
        do {
            let csvString = try String(contentsOf: url, encoding: .utf8)
            let lines = csvString.split(separator: "\n").map { String($0) }
            guard lines.count > 1 else { return }
            
            let headers = lines[0]
            let fieldOrder = FieldOrder(headers: headers.split(separator: ",").map { String($0) })
            
            self.items = lines.dropFirst().compactMap { TodoItem.parse(csv: "\(headers)\n\($0)") }
        } catch {
            print("Error loading from file: \(error)")
        }
    }

    
    func serialize(items: [TodoItem]) -> Data? {
        let dictArray = items.map { $0.dict }
        return try? JSONSerialization.data(withJSONObject: dictArray, options: [])
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

}


