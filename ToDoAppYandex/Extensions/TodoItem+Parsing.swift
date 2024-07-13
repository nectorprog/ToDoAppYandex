import Foundation

extension TodoItem {
    static func parse(json: Any) -> TodoItem? {
        guard let jsonData = (json as? String)?.data(using: .utf8) else {
            return nil
        }
        
        do {
            if let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                let id = jsonObject["id"] as? String ?? UUID().uuidString
                guard let text = jsonObject["text"] as? String else { return nil }
                
                let importanceString = jsonObject["importance"] as? String ?? Importance.medium.rawValue
                let importance = Importance(rawValue: importanceString) ?? .medium
                
                let deadline: Date?
                if let deadlineTimeInterval = jsonObject["deadline"] as? TimeInterval {
                    deadline = Date(timeIntervalSince1970: deadlineTimeInterval)
                } else {
                    deadline = nil
                }
                
                let isReady = jsonObject["isReady"] as? Bool ?? false
                
                let createdAt: Date
                if let createdAtTimeInterval = jsonObject["createdAt"] as? TimeInterval {
                    createdAt = Date(timeIntervalSince1970: createdAtTimeInterval)
                } else if let createdAtString = jsonObject["createdAt"] as? String, let createdAtTimeInterval = TimeInterval(createdAtString) {
                    createdAt = Date(timeIntervalSince1970: createdAtTimeInterval)
                } else {
                    return nil
                }
                
                let updatedAt: Date?
                if let updatedAtTimeInteval = jsonObject["updatedAt"] as? TimeInterval {
                    updatedAt = Date(timeIntervalSince1970: updatedAtTimeInteval)
                } else {
                    updatedAt = nil
                }
                
                return TodoItem(id: id, text: text, importance: importance, deadline: deadline, isReady: isReady, createdAt: createdAt, updatedAt: updatedAt)
            }
        } catch {
            print("Error parsing JSON: \(error)")
        }
        
        return nil
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
