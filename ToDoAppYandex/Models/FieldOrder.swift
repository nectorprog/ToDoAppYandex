struct FieldOrder {
    var idIndex: Int?
    var textIndex: Int?
    var importanceIndex: Int?
    var deadlineIndex: Int?
    var isReadyIndex: Int?
    var createdAtIndex: Int?
    var updatedAtIndex: Int?
    
    init(headers: [String]) {
        for (index, header) in headers.enumerated() {
            switch header {
                case "id":
                    idIndex = index
                case "text":
                    textIndex = index
                case "importance":
                    importanceIndex = index
                case "deadline":
                    deadlineIndex = index
                case "isReady":
                    isReadyIndex = index
                case "createdAt":
                    createdAtIndex = index
                case "updatedAt":
                    updatedAtIndex = index
                default:
                    break
            }
        }
    }
}
