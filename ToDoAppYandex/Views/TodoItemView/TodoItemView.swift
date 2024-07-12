import SwiftUI
import CocoaLumberjackSwift

struct TodoItemView: View {
    @Binding var isPresented: Bool
    @ObservedObject var viewModel: TodoListViewModel
    @State private var text: String = ""
    @State private var importance: Importance = .medium
    @State private var isDeadlineOn: Bool = false
    @State private var deadline: Date = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    @State private var showingCalendar = false
    @State private var isEditing = false
    @State private var selectedColor: Color = .blue
    @State private var showingColorPicker = false
    @State private var selectedCategory: TaskCategory = .other
    
    var onDismiss: (() -> Void)?
    var editingItem: TodoItem?
    var isNewTask: Bool
    
    init(isPresented: Binding<Bool>, viewModel: TodoListViewModel, isNewTask: Bool, editingItem: TodoItem? = nil, onDismiss: (() -> Void)? = nil) {
        self._isPresented = isPresented
        self.viewModel = viewModel
        self.isNewTask = isNewTask
        self.editingItem = editingItem
        self.onDismiss = onDismiss
        
        if let item = editingItem {
            _text = State(initialValue: item.text)
            _importance = State(initialValue: item.importance)
            _isDeadlineOn = State(initialValue: item.deadline != nil)
            _deadline = State(initialValue: item.deadline ?? Date())
            _selectedCategory = State(initialValue: item.category)
            _selectedColor = State(initialValue: Color(hex: item.color))
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Form {
                    Section {
                        TodoItemTextView(text: $text, isEditing: $isEditing)
                            .overlay(
                                Rectangle()
                                    .fill(selectedColor)
                                    .frame(width: 5)
                                    .padding(.trailing, -20),
                                alignment: .trailing
                            )
                    }
                    
                    Section {
                        ImportancePicker(importance: $importance)
                        
                        Picker("Категория", selection: $selectedCategory) {
                            ForEach(TaskCategory.allCases) { category in
                                HStack {
                                    Circle()
                                        .fill(category.color)
                                        .frame(width: 20, height: 20)
                                    Text(category.rawValue)
                                }
                                .tag(category)
                            }
                        }
                        
                        Button(action: {
                            showingColorPicker = true
                        }) {
                            HStack {
                                Text("Цвет")
                                    .foregroundStyle(Color.lPrimary)
                                Spacer()
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(selectedColor)
                                    .frame(width: 30, height: 30)
                            }
                        }
                        
                        DeadlinePicker(isOn: $isDeadlineOn, date: $deadline, showingCalendar: $showingCalendar)
                        
                        if isDeadlineOn {
                            if showingCalendar {
                                DatePicker("Выберите дату", selection: $deadline, in: Date()..., displayedComponents: .date)
                                    .datePickerStyle(GraphicalDatePickerStyle())
                                    .frame(height: 300)
                                    .transition(.move(edge: .top).combined(with: .opacity))
                                    .animation(.easeInOut, value: showingCalendar)
                            }
                        }
                    }
                    
                    Section {
                        Button(action: {
                            if let item = editingItem {
                                viewModel.deleteTodoItem(item)
                                isPresented = false
                                onDismiss?()
                            }
                        }) {
                            Text("Удалить")
                                .foregroundColor(isNewTask ? Color.lDisable : Color.cRed)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .disabled(isNewTask)
                    }
                }
                
                if isEditing {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            hideKeyboard()
                            isEditing = false
                        }
                }
            }
            .sheet(isPresented: $showingColorPicker) {
                CustomColorPicker(selectedColor: $selectedColor)
            }
            .navigationTitle("Дело")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отменить") {
                        isPresented = false
                        onDismiss?()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            let updatedItem = TodoItem(
                                id: editingItem?.id ?? UUID().uuidString,
                                text: text,
                                importance: importance,
                                deadline: isDeadlineOn ? deadline : nil,
                                isReady: editingItem?.isReady ?? false,
                                createdAt: editingItem?.createdAt ?? Date(),
                                updatedAt: Date(),
                                color: selectedColor.hexString,
                                category: selectedCategory
                                
                            )
                            
                            if isNewTask {
                                viewModel.addTodoItem(updatedItem)
                            } else {
                                viewModel.updateTodoItem(updatedItem)
                            }
                            
                            isPresented = false
                            onDismiss?()
                        }
                    }
                    .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .onAppear {
            DDLogDebug("TodoItemView appeared for item: \(editingItem?.text ?? "New Item")")
        }
        .onDisappear {
            DDLogDebug("TodoItemView disappeared for item: \(editingItem?.text ?? "New Item")")
        }
    }
}
