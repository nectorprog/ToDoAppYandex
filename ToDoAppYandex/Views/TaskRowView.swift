import SwiftUI

struct TaskRowView: View {
    @State var task: TodoItem
    var onDelete: () -> Void
    var onEdit: () -> Void
    var onToggleReady: () -> Void

    var body: some View {
        HStack {
            RadioButtonStyle(isReady: task.isReady, importance: task.importance)
            VStack(alignment: .leading) {
                Text(task.text)
                    .lineLimit(3)
                    .truncationMode(.tail)
                    .font(.body)
                    .strikethrough(task.isReady, color: .gray)
                    .foregroundColor(task.isReady ? .gray : .primary)

                if let deadline = task.deadline {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.gray)
                        Text(formatDate(deadline))
                            .font(.subheadline)
                            .foregroundColor(Color.lTertiary)
                    }
                }
            }
            Spacer()
            Rectangle()
                .fill(Color(hex: task.colorHex) ?? .clear)
                .frame(width: 5)
        }
        .padding()
        .background(Color.bSecondary)
        .cornerRadius(10)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
            
            Button {
                onEdit()
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            .tint(.blue)
        }
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            Button(action: {
                onToggleReady()
            }) {
                ZStack {
                    Rectangle()
                        .fill(Color.green)
                    Circle()
                        .fill(Color.white)
                        .frame(width: 24, height: 24)
                    Image(systemName: "checkmark")
                        .foregroundColor(.green)
                        .font(.system(size: 12))
                }
                .frame(width: 40, height: 40)
            }
            .tint(.green)
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
}

#Preview {
    TaskRowView(task: TodoItem(text: "Купить что-то", importance: .medium, createdAt: Date(timeIntervalSinceNow: -10000)), onDelete: {}, onEdit: {}, onToggleReady: {})
}
