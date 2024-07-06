import SwiftUI

struct AddTaskView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: TaskViewModel
    @Binding var taskIndex: Int?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass

    @State private var taskText: String = ""
    @State private var importance: Importance = .medium
    @State private var isDeadlineEnabled: Bool = false
    @State private var deadline: Date = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
    @State private var showDatePicker: Bool = false
    @State private var isEditingText: Bool = false
    @State private var isLandscape: Bool = false
    @State private var selectedColor: Color = .blue
    @State private var showColorPicker = false

    var body: some View {
        GeometryReader { geometry in
            VStack {
                if isLandscape {
                    HStack {
                        TextEditor(text: $taskText)
                            .padding()
                            .background(Color.bSecondary)
                            .cornerRadius(10)
                            .font(.body)
                            .frame(width: isEditingText ? geometry.size.width : geometry.size.width / 2)
                            .onTapGesture {
                                isEditingText = true
                            }
                        
                        if !isEditingText {
                            ScrollView {
                                VStack(alignment: .leading, spacing: 20) {
                                    VStack(spacing: 20) {
                                        HStack {
                                            Text("Важность")
                                            Spacer()
                                            ImportanceSelectionView(importance: $importance)
                                                .padding(.horizontal, 10)
                                                .cornerRadius(8)
                                        }
                                        Divider()
                                        VStack(alignment: .leading) {
                                            HStack {
                                                Text("Сделать до")
                                                Spacer()
                                                Toggle("", isOn: $isDeadlineEnabled)
                                                    .onChange(of: isDeadlineEnabled) { value in
                                                        if value {
                                                            deadline = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
                                                        }
                                                    }
                                                    .labelsHidden()
                                            }
                                            if isDeadlineEnabled {
                                                Button(action: {
                                                    showDatePicker.toggle()
                                                }) {
                                                    Text(formatDate(deadline))
                                                        .foregroundColor(.blue)
                                                }
                                                if showDatePicker {
                                                    DatePicker(
                                                        "",
                                                        selection: $deadline,
                                                        in: Date()...,
                                                        displayedComponents: .date
                                                    )
                                                    .datePickerStyle(GraphicalDatePickerStyle())
                                                }
                                            }
                                        }
                                        Divider()
                                        HStack {
                                            Text("Цвет задачи")
                                            Spacer()
                                            Rectangle()
                                                .fill(selectedColor)
                                                .frame(width: 30, height: 30)
                                                .cornerRadius(5)
                                                .onTapGesture {
                                                    showColorPicker.toggle()
                                                }
                                        }
                                        if showColorPicker {
                                            ColorPicker("Выберите цвет", selection: $selectedColor)
                                                .onChange(of: selectedColor) { newValue in
                                                    // Handle color change if needed
                                                }
                                        }
                                    }
                                    .padding()
                                    .background(Color.bSecondary)
                                    .cornerRadius(10)
                                    .padding(.horizontal)
                                    
                                    Button("Удалить") {
                                        if let index = taskIndex {
                                            viewModel.deleteTask(at: index)
                                            presentationMode.wrappedValue.dismiss()
                                        }
                                    }
                                    .foregroundColor(.red)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.cWhite)
                                    .cornerRadius(10)
                                    .padding(.horizontal)
                                    .disabled(taskIndex == nil)
                                }
                                .background(Color.bPrimary)
                            }
                        }
                    }
                    .background(Color.bPrimary)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        hideKeyboard()
                        isEditingText = false
                    }
                } else {
                    VStack {
                        HStack {
                            Button("Отменить") {
                                presentationMode.wrappedValue.dismiss()
                            }
                            Spacer()
                            Text("Дело")
                                .font(.headline)
                            Spacer()
                            Button("Сохранить") {
                                saveTask()
                                presentationMode.wrappedValue.dismiss()
                            }
                            .disabled(taskText.isEmpty)
                            .foregroundColor(taskText.isEmpty ? .gray : .blue)
                        }
                        .padding()
                        .background(Color.bPrimary)

                        ScrollView {
                            VStack(alignment: .leading, spacing: 20) {
                                TextEditor(text: $taskText)
                                    .padding()
                                    .background(Color.bSecondary)
                                    .cornerRadius(10)
                                    .frame(minHeight: 100, maxHeight: .infinity)
                                    .font(.body)
                                    .onTapGesture {
                                        isEditingText = true
                                    }
                                
                                VStack(spacing: 20) {
                                    HStack {
                                        Text("Важность")
                                        Spacer()
                                        ImportanceSelectionView(importance: $importance)
                                            .padding(.horizontal, 10)
                                            .cornerRadius(8)
                                    }
                                    Divider()
                                    VStack(alignment: .leading) {
                                        HStack {
                                            Text("Сделать до")
                                            Spacer()
                                            Toggle("", isOn: $isDeadlineEnabled)
                                                .onChange(of: isDeadlineEnabled) { value in
                                                    if value {
                                                        deadline = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
                                                    }
                                                }
                                                .labelsHidden()
                                        }
                                        if isDeadlineEnabled {
                                            Button(action: {
                                                showDatePicker.toggle()
                                            }) {
                                                Text(formatDate(deadline))
                                                    .foregroundColor(.blue)
                                            }
                                            if showDatePicker {
                                                DatePicker(
                                                    "",
                                                    selection: $deadline,
                                                    in: Date()...,
                                                    displayedComponents: .date
                                                )
                                                .datePickerStyle(GraphicalDatePickerStyle())
                                            }
                                        }
                                        Divider()
                                        HStack {
                                            Text("Цвет задачи")
                                            Spacer()
                                            Rectangle()
                                                .fill(selectedColor)
                                                .frame(width: 30, height: 30)
                                                .cornerRadius(5)
                                                .onTapGesture {
                                                    showColorPicker.toggle()
                                                }
                                        }
                                        if showColorPicker {
                                            ColorPicker("Выберите цвет", selection: $selectedColor)
                                                .onChange(of: selectedColor) { newValue in
                                                    // Handle color change if needed
                                                }
                                        }
                                    }
                                }
                                .padding()
                                .background(Color.bSecondary)
                                .cornerRadius(10)
                                .padding(.horizontal)
                                
                                Button("Удалить") {
                                    if let index = taskIndex {
                                        viewModel.deleteTask(at: index)
                                        presentationMode.wrappedValue.dismiss()
                                    }
                                }
                                .foregroundColor(.red)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.cWhite)
                                .cornerRadius(10)
                                .padding(.horizontal)
                                .disabled(taskIndex == nil)
                            }
                            .background(Color.bPrimary)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            hideKeyboard()
                            isEditingText = false
                        }
                    }
                }
            }
            .background(Color.bPrimary)
            .edgesIgnoringSafeArea(.all)
            .onRotate { newOrientation in
                isLandscape = newOrientation.isLandscape
            }
            .onAppear {
                if let index = taskIndex {
                    let task = viewModel.tasks[index]
                    taskText = task.text
                    importance = task.importance
                    selectedColor = Color(hex: task.colorHex) ?? .blue
                    if let deadline = task.deadline {
                        isDeadlineEnabled = true
                        self.deadline = deadline
                    } else {
                        isDeadlineEnabled = false
                    }
                }
                // Check the initial orientation on appear
                isLandscape = horizontalSizeClass == .regular && verticalSizeClass == .compact
            }
        }
    }

    private func saveTask() {
        if let index = taskIndex {
            var task = viewModel.tasks[index]
            task.text = taskText
            task.importance = importance
            task.colorHex = selectedColor.toHex ?? "#0000FF" // Default to blue if color conversion fails
            task.deadline = isDeadlineEnabled ? deadline : nil
            task.updatedAt = Date()
            viewModel.updateTask(task)
        } else {
            let newItem = TodoItem(
                text: taskText,
                importance: importance,
                deadline: isDeadlineEnabled ? deadline : nil, colorHex: selectedColor.toHex ?? "#0000FF"
            )
            viewModel.addTask(newItem)
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct AddTaskView_Previews: PreviewProvider {
    static var previews: some View {
        AddTaskView(taskIndex: .constant(nil)).environmentObject(TaskViewModel())
    }
}

extension View {
    func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        self.modifier(DeviceRotationViewModifier(action: action))
    }
}

struct DeviceRotationViewModifier: ViewModifier {
    let action: (UIDeviceOrientation) -> Void

    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                action(UIDevice.current.orientation)
            }
    }
}
