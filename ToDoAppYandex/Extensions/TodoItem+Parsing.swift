import Foundation

extension TodoItem {
    // JSON
    public static func parse(json: String) -> TodoItem? {
        guard let data = json.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
              let dictionary = jsonObject as? [String: Any] else {
            return nil
        }

        guard let id = dictionary["id"] as? String,
              let text = dictionary["text"] as? String,
              let isReady = dictionary["isReady"] as? Bool,
              let createdAtTimestamp = dictionary["createdAt"] as? Int else {
            return nil
        }

        let createdAt = Date.from(unixTimestamp: createdAtTimestamp)
        let importanceRaw = dictionary["importance"] as? String
        let importance = importanceRaw.flatMap { Importance(rawValue: $0) } ?? .medium

        var deadline: Date? = nil
        if let deadlineTimestamp = dictionary["deadline"] as? Int {
            deadline = Date.from(unixTimestamp: deadlineTimestamp)
        }

        var updatedAt: Date? = nil
        if let updatedAtTimestamp = dictionary["updatedAt"] as? Int {
            updatedAt = Date.from(unixTimestamp: updatedAtTimestamp)
        }

        return TodoItem(id: id, text: text, importance: importance, deadline: deadline, isReady: isReady, createdAt: createdAt, updatedAt: updatedAt)
    }

    var json: String {
        var jsonDict = [String: Any]()
        jsonDict["id"] = id
        jsonDict["text"] = text
        if importance != .medium {
            jsonDict["importance"] = importance.rawValue
        }
        jsonDict["isReady"] = isReady
        jsonDict["createdAt"] = createdAt.unixTimestamp
        if let deadline = deadline {
            jsonDict["deadline"] = deadline.unixTimestamp
        }
        if let updatedAt = updatedAt {
            jsonDict["updatedAt"] = updatedAt.unixTimestamp
        }

        if let jsonData = try? JSONSerialization.data(withJSONObject: jsonDict, options: []),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        }
        return "{}"
    }

    // CSV
    public static func parse(csv: String) -> TodoItem? {
        let rows = csv.components(separatedBy: "\n")
        guard rows.count == 2 else { return nil }

        let headers = rows[0].components(separatedBy: ",")
        let values = rows[1].components(separatedBy: ",")
        guard headers.count == values.count else { return nil }

        guard let idIndex = headers.firstIndex(of: "id"),
              let textIndex = headers.firstIndex(of: "text"),
              let importanceIndex = headers.firstIndex(of: "importance"),
              let isReadyIndex = headers.firstIndex(of: "isReady"),
              let createdAtIndex = headers.firstIndex(of: "createdAt"),
              let deadlineIndex = headers.firstIndex(of: "deadline"),
              let updatedAtIndex = headers.firstIndex(of: "updatedAt") else { return nil }

        let id = values[idIndex]
        let text = values[textIndex]
        let importance = Importance(rawValue: values[importanceIndex]) ?? .medium
        let isReady = Bool(values[isReadyIndex]) ?? false
        let createdAt = Date.from(unixTimestamp: Int(values[createdAtIndex]) ?? 0)
        var deadline: Date? = nil
        if !values[deadlineIndex].isEmpty {
            deadline = Date.from(unixTimestamp: Int(values[deadlineIndex]) ?? 0)
        }
        var updatedAt: Date? = nil
        if !values[updatedAtIndex].isEmpty {
            updatedAt = Date.from(unixTimestamp: Int(values[updatedAtIndex]) ?? 0)
        }

        return TodoItem(id: id, text: text, importance: importance, deadline: deadline, isReady: isReady, createdAt: createdAt, updatedAt: updatedAt)
    }

    var toCSV: String {
        let headers = ["id", "text", "importance", "isReady", "createdAt", "deadline", "updatedAt"]
        var values = [String]()
        values.append(id)
        values.append(text)
        values.append(importance != .medium ? importance.rawValue : "")
        values.append(String(isReady))
        values.append("\(createdAt.unixTimestamp)")
        values.append(deadline != nil ? "\(deadline!.unixTimestamp)" : "")
        values.append(updatedAt != nil ? "\(updatedAt!.unixTimestamp)" : "")

        return headers.joined(separator: ",") + "\n" + values.joined(separator: ",")
    }
}
