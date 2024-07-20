import SwiftUI
import CocoaLumberjackSwift

struct TaskListView: View {
    @StateObject private var viewModel = TodoListViewModel()
    @State private var isShowingNewTask = false
    @State private var showCompleted = true
    @State private var isShowingCalendar = false
    @State private var editingItem: TodoItem?
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                Color.bPrimary.ignoresSafeArea()
                
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
                    
                    if viewModel.isDirty {
                        HStack {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(.yellow)
                            Text("Есть несинхронизированные изменения")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Button("Синхронизировать") {
                                viewModel.synchronize()
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 10)
                    }
                    
                    HStack {
                        Text("Выполнено — \(viewModel.todoItems.filter { $0.isReady }.count)")
                            .foregroundColor(.secondary)
                        Spacer()
                        Button(showCompleted ? "Скрыть" : "Показать") {
                            showCompleted.toggle()
                        }
                        .foregroundColor(.blue)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                    
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(1.5)
                            .padding()
                    } else {
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
                            .onDelete { indexSet in
                                for index in indexSet {
                                    let item = viewModel.todoItems[index]
                                    viewModel.deleteTodoItem(item)
                                }
                            }
                        }
                        .listStyle(PlainListStyle())
                    }
                }
                
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
            .navigationBarHidden(true)
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
        .alert(item: Binding<ErrorWrapper?>(
            get: { viewModel.error.map { ErrorWrapper(error: $0) } },
            set: { _ in viewModel.error = nil }
        )) { errorWrapper in
            Alert(title: Text("Ошибка"), message: Text(errorWrapper.error), dismissButton: .default(Text("OK")))
        }
        .onAppear {
            DDLogInfo("Task list view appeared")
        }
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM"
        return formatter.string(from: date)
    }
}

struct ErrorWrapper: Identifiable {
    let id = UUID()
    let error: String
}
