import Foundation

extension TodoItem {
    static func parse(json: Any) -> TodoItem? {
            guard let dictionary = json as? [String: Any],
                  let id = dictionary["id"] as? String,
                  let text = dictionary["text"] as? String,
                  let isReady = dictionary["isReady"] as? Bool,
                  let createdAtString = dictionary["createdAt"] as? String,
                  let createdAt = ISO8601DateFormatter().date(from: createdAtString)
            else {
                return nil
            }
            
            let updatedAtString = dictionary["updatedAt"] as? String
            let updatedAt = updatedAtString != nil ? ISO8601DateFormatter().date(from: updatedAtString!) : nil
            
            let importanceRaw = dictionary["importance"] as? String
            let importance = importanceRaw.flatMap { Importance(rawValue: $0) } ?? .medium
            
            let deadlineString = dictionary["deadline"] as? String
            let deadline = deadlineString != nil ? ISO8601DateFormatter().date(from: deadlineString!) : nil

            return TodoItem(id: id, text: text, importance: importance, deadline: deadline, isReady: isReady, createdAt: createdAt, updatedAt: updatedAt)
        }
    
    var json: Any {
        var dictionary = [String: Any]()
        dictionary["id"] = self.id
        dictionary["text"] = self.text
        dictionary["isReady"] = self.isReady
        
        if importance != .medium {
            dictionary["importance"] = importance.rawValue
        }
        
        if let deadline = self.deadline {
            dictionary["deadline"] = ISO8601DateFormatter().string(from: deadline)
        }
        
        return dictionary
    }
}

