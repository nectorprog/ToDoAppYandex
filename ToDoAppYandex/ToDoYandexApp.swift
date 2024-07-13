import SwiftUI
import SwiftData
import CocoaLumberjackSwift

@main
struct ToDoYandexApp: App {
    init() {
        LoggerSetup.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            TaskListView()
        }
    }
}
