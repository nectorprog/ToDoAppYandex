import Foundation

extension TodoItem {
    static func parse(json: [String: Any]) -> TodoItem? {
        guard let id = json["id"] as? String,
              let text = json["text"] as? String,
              let createdAt = json["created_at"] as? TimeInterval,
              let changedAt = json["changed_at"] as? TimeInterval,
              let done = json["done"] as? Bool,
              let lastUpdatedBy = json["last_updated_by"] as? String else {
            print("Failed to parse required fields")
            return nil
        }
        
        let importanceString = json["importance"] as? String ?? "basic"
        let importance: Importance
        switch importanceString {
        case "low":
            importance = .low
        case "basic":
            importance = .medium
        case "important":
            importance = .high
        default:
            importance = .medium
        }
        
        let deadline: Date?
        if let deadlineTimeInterval = json["deadline"] as? TimeInterval {
            deadline = Date(timeIntervalSince1970: deadlineTimeInterval)
        } else {
            deadline = nil
        }
        
        let color = json["color"] as? String
        
        return TodoItem(
            id: id,
            text: text,
            importance: importance,
            deadline: deadline,
            isReady: done,
            createdAt: Date(timeIntervalSince1970: createdAt),
            updatedAt: Date(timeIntervalSince1970: changedAt),
            color: color ?? "#FFFFFF",
            lastUpdatedBy: lastUpdatedBy
        )
    }
    
    var json: Any {
        var jsonDict = [String: Any]()
        jsonDict["id"] = id
        jsonDict["text"] = text
        if importance != .medium {
            jsonDict["importance"] = importance.rawValue
        }
        
        if let deadline {
            jsonDict["deadline"] = deadline.timeIntervalSince1970
        }
        
        jsonDict["isReady"] = isReady
        jsonDict["createdAt"] = createdAt.timeIntervalSince1970
        
        if let updatedAt {
            jsonDict["updatedAt"] = updatedAt.timeIntervalSince1970
        }
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: jsonDict, options: []),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        }

        return "{}"
    }
    
    static func parse(csv: String) -> TodoItem? {
        let lines = csv.split(separator: "\n").map { String($0) }
        guard lines.count >= 2 else { return nil }
        
        let headers = lines[0].split(separator: ",").map { String($0) }
        let values = lines[1].split(separator: ",").map { String($0) }
        
        let fieldOrder = FieldOrder(headers: headers)
        
        guard let textIndex = fieldOrder.textIndex, textIndex < values.count else { return nil }
        
        let id: String
        if let idIndex = fieldOrder.idIndex, idIndex < values.count {
            id = values[idIndex]
        } else {
            id = UUID().uuidString
        }
        
        let text = values[textIndex]
        
        let importance: Importance
        if let importanceIndex = fieldOrder.importanceIndex, importanceIndex < values.count, !values[importanceIndex].isEmpty {
            importance = Importance(rawValue: values[importanceIndex]) ?? .medium
        } else {
            importance = .medium
        }
        
        let deadline: Date?
        if let deadlineIndex = fieldOrder.deadlineIndex, deadlineIndex < values.count, let timeInterval = TimeInterval(values[deadlineIndex]), !values[deadlineIndex].isEmpty {
            deadline = Date(timeIntervalSince1970: timeInterval)
        } else {
            deadline = nil
        }
        
        let isReady: Bool
        if let isReadyIndex = fieldOrder.isReadyIndex, isReadyIndex < values.count {
            isReady = values[isReadyIndex] == "true"
        } else {
            isReady = false
        }
        
        let createdAt: Date
        if let createdAtIndex = fieldOrder.createdAtIndex, createdAtIndex < values.count, let timeInterval = TimeInterval(values[createdAtIndex]) {
            createdAt = Date(timeIntervalSince1970: timeInterval)
        } else {
            createdAt = Date()
        }
        
        let updatedAt: Date?
        if let updatedAtIndex = fieldOrder.updatedAtIndex, updatedAtIndex < values.count, let timeInterval = TimeInterval(values[updatedAtIndex]), !values[updatedAtIndex].isEmpty {
            updatedAt = Date(timeIntervalSince1970: timeInterval)
        } else {
            updatedAt = nil
        }
        
        return TodoItem(id: id, text: text, importance: importance, deadline: deadline, isReady: isReady, createdAt: createdAt, updatedAt: updatedAt)
    }
    
    var csv: String {
        var headers = [String]()
        var values = [String]()
        
        headers.append("id")
        values.append(id)
        
        headers.append("text")
        values.append(text)
        
        headers.append("importance")
        values.append(importance.rawValue)
        
        if let deadline = deadline {
            headers.append("deadline")
            values.append(String(deadline.timeIntervalSince1970))
        }
        
        headers.append("isReady")
        values.append(String(isReady))
        
        headers.append("createdAt")
        values.append(String(createdAt.timeIntervalSince1970))
        
        if let updatedAt = updatedAt {
            headers.append("updatedAt")
            values.append(String(updatedAt.timeIntervalSince1970))
        }
        
        let headerString = headers.joined(separator: ",")
        let valueString = values.joined(separator: ",")
        
        return "\(headerString)\n\(valueString)"
    }
    
}
