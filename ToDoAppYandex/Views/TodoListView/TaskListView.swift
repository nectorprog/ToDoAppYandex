import SwiftUI

struct TaskListView: View {
    @StateObject private var viewModel = TodoListViewModel()
    @State private var isShowingNewTask = false
    @State private var showCompleted = true
    @State private var isShowingCalendar = false
    @State private var editingItem: TodoItem?
    @State private var isShowingSettings = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.bPrimary.ignoresSafeArea()
            
            NavigationView {
                VStack(spacing: 0) {
                    HStack {
                        Text("Мои дела")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Spacer()
                        Button(action: {
                            isShowingCalendar = true
                        }) {
                            Image(systemName: "calendar")
                                .font(.title2)
                        }
                    }
                    .padding()
                    
                    HStack {
                        Text("Выполнено — \(viewModel.todoItems.filter { $0.isReady }.count)")
                            .foregroundColor(.secondary)
                        Spacer()
                        Button(showCompleted ? "Скрыть" : "Показать") {
                            showCompleted.toggle()
                        }
                        .foregroundColor(.blue)
                    }
                    .padding(.top, 10)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                    
                    List {
                        ForEach(viewModel.todoItems.filter { showCompleted || !$0.isReady }, id: \.id) { item in
                            HStack {
                                RadioButtonStyle(isReady: item.isReady, importance: item.importance)
                                    .onTapGesture {
                                        var updatedItem = item
                                        updatedItem.isReady.toggle()
                                        viewModel.updateTodoItem(updatedItem)
                                    }
                                
                                VStack(alignment: .leading) {
                                    Text(item.text)
                                        .strikethrough(item.isReady)
                                    if let deadline = item.deadline {
                                        Text(formatDate(deadline))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Spacer()
                                
                                Rectangle()
                                    .fill(Color(hex: item.color))
                                    .frame(width: 5, height: 30)
                            }
                            .onTapGesture {
                                editingItem = item
                            }
                        }
                        .background(Color.clear)
                    }
                    .listStyle(PlainListStyle())
                    
                    
                        Spacer()
                        Button(action: {
                            isShowingNewTask = true
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .background(Color.cBlue)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                        .padding(.bottom, 16)
                }
            }
            .sheet(isPresented: $isShowingNewTask) {
                TodoItemView(isPresented: $isShowingNewTask, viewModel: viewModel, isNewTask: true)
            }
            .sheet(isPresented: $isShowingCalendar) {
                CalendarViewControllerRepresentable(viewModel: viewModel)
            }
            .sheet(item: $editingItem) { item in
                TodoItemView(isPresented: .constant(true), viewModel: viewModel, isNewTask: false, editingItem: item) {
                    editingItem = nil
                }
            }
        }
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM"
        return formatter.string(from: date)
    }
}
