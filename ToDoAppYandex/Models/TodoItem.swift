import Foundation

struct TodoItem: Equatable, Identifiable{
    let id: String
    var text: String
    var importance: Importance
    var deadline: Date?
    var isReady: Bool
    var createdAt: Date
    var updatedAt: Date?
    var colorHex: String
    
    init(
        id: String = UUID().uuidString,
        text: String,
        importance: Importance,
        deadline: Date? = nil,
        isReady: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date? = nil,
        colorHex: String = "#FFFFFF"
    ) {
        self.id = id
        self.text = text
        self.importance = importance
        self.deadline = deadline
        self.isReady = isReady
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.colorHex = colorHex
    }
    
    var dict: [String: Any] {
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
        
        return jsonDict
    }
    
    static func from(dict: [String: Any]) -> TodoItem? {
        guard let id = dict["id"] as? String,
              let text = dict["text"] as? String,
              let isReady = dict["isReady"] as? Bool,
              let createdAtTimeInterval = dict["createdAt"] as? TimeInterval else {
            return nil
        }
        
        let createdAt = Date(timeIntervalSince1970: createdAtTimeInterval)
        
        let importance: Importance
        if let importanceString = dict["importance"] as? String,
           let imp = Importance(rawValue: importanceString) {
            importance = imp
        } else {
            importance = .medium
        }
        
        let deadline: Date?
        if let deadlineTimeInterval = dict["deadline"] as? TimeInterval {
            deadline = Date(timeIntervalSince1970: deadlineTimeInterval)
        } else {
            deadline = nil
        }
        
        let updatedAt: Date?
        if let updatedAtTimeInterval = dict["updatedAt"] as? TimeInterval {
            updatedAt = Date(timeIntervalSince1970: updatedAtTimeInterval)
        } else {
            updatedAt = nil
        }

        return TodoItem(id: id, text: text, importance: importance, deadline: deadline, isReady: isReady, createdAt: createdAt, updatedAt: updatedAt)
    }
    
    static func ==(lhs: TodoItem, rhs: TodoItem) -> Bool {
        return lhs.id == rhs.id &&
               lhs.text == rhs.text &&
               lhs.importance == rhs.importance &&
               ((lhs.deadline == nil && rhs.deadline == nil) || (lhs.deadline?.isEqualRounded(to: rhs.deadline, precision: 1.0) ?? false)) &&
               lhs.isReady == rhs.isReady &&
               lhs.createdAt.isEqualRounded(to: rhs.createdAt, precision: 1.0) &&
               ((lhs.updatedAt == nil && rhs.updatedAt == nil) || (lhs.updatedAt?.isEqualRounded(to: rhs.updatedAt, precision: 1.0) ?? false))
    }
}
