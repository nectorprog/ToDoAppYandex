import SwiftUI
import Foundation

struct ContentView: View {
    @StateObject private var viewModel = TaskViewModel()
    @State private var showCompletedTasks: Bool = false
    @State private var showAddTaskView = false
    @State private var selectedTaskIndex: Int?

    var body: some View {
        VStack {
            HStack {
                Text("Мои дела")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.lPrimary)
                
                Spacer()
            }
            .padding(.top)
            .padding(.bottom)
            .padding(.horizontal, 30.0)
            
            HStack {
                Text("Выполнено — \(viewModel.tasks.filter { $0.isReady }.count)")
                    .font(.subheadline)
                    .foregroundStyle(Color.lTertiary)
                
                Spacer()
                
                Button(action: {
                    showCompletedTasks.toggle()
                }) {
                    Text(showCompletedTasks ? "Скрыть" : "Показать")
                        .font(.subheadline)
                        .foregroundStyle(Color.cBlue)
                }
            }
            .padding(.horizontal, 30.0)
            
            TaskListView(tasks: filteredTasks, onDelete: deleteTask, onEdit: editTask, onToggleReady: toggleReady)
                .padding(.horizontal)
            
            Spacer()
            
            Button(action: {
                selectedTaskIndex = nil
                showAddTaskView.toggle()
            }) {
                Image(systemName: "plus")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.cBlue)
                    .clipShape(Circle())
                    .shadow(radius: 10)
            }
            .padding()
            .sheet(isPresented: $showAddTaskView) {
                AddTaskView(taskIndex: $selectedTaskIndex)
                    .environmentObject(viewModel)
            }
        }
        .background(Color.biPrimary)
    }

    private var filteredTasks: [TodoItem] {
        viewModel.tasks
            .filter { showCompletedTasks || !$0.isReady }
            .sorted { $0.createdAt < $1.createdAt }
    }
    
    private func deleteTask(at index: Int) {
        viewModel.tasks.remove(at: index)
    }

    private func editTask(at index: Int) {
        selectedTaskIndex = index
        showAddTaskView.toggle()
    }

    private func toggleReady(at index: Int) {
        viewModel.tasks[index].isReady.toggle()
    }
}

#Preview {
    ContentView()
}
