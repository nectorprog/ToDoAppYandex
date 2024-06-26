struct FieldOrder {
    let idIndex: Int?
    let textIndex: Int?
    let importanceIndex: Int?
    let deadlineIndex: Int?
    let isReadyIndex: Int?
    let createdAtIndex: Int?
    let updatedAtIndex: Int?

    init(headers: [String]) {
        idIndex = headers.firstIndex(of: "id")
        textIndex = headers.firstIndex(of: "text")
        importanceIndex = headers.firstIndex(of: "importance")
        deadlineIndex = headers.firstIndex(of: "deadline")
        isReadyIndex = headers.firstIndex(of: "isReady")
        createdAtIndex = headers.firstIndex(of: "createdAt")
        updatedAtIndex = headers.firstIndex(of: "updatedAt")
    }
}
