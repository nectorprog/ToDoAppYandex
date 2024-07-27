import SwiftUI
import SwiftData
import CocoaLumberjackSwift

@main
struct ToDoYandexApp: App {
    let sharedModelContainer: ModelContainer
    
    init() {
        LoggerSetup.configure()
        
        do {
            let schema = Schema([TodoItem.self])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            sharedModelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            TaskListView()
        }
        .modelContainer(sharedModelContainer)
    }
}
