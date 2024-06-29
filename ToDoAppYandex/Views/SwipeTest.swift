import SwiftUI

struct SwipeTest: View {
    @State private var items = ["Item 1", "Item 2", "Item 3"]

    var body: some View {
        NavigationView {
            List {
                ForEach(items, id: \.self) { item in
                    Text(item)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(action: {
                                if let index = items.firstIndex(of: item) {
                                    items.remove(at: index)
                                }
                            }) {
                                Label("Delete", systemImage: "trash")
                            }
                            .tint(.red)
                            
                            Button(action: {
                                // Действие для info
                            }) {
                                Label("Info", systemImage: "info.circle")
                            }
                            .tint(.gray)
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            Button(action: {
                                // Действие для checkmark
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
            }
            .navigationTitle("Swipe Actions")
        }
    }
}

#Preview {
    SwipeTest()
}
