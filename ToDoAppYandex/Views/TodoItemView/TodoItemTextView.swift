import SwiftUI

struct TodoItemTextView: View {
    @Binding var text: String
    @Binding var isEditing: Bool
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                VStack {
                    Text("Что надо сделать?")
                        .padding(.top, 10)
                        .padding(.leading, 6)
                        .font(.body)
                        .foregroundStyle(Color.lTertiary)
                    
                    Spacer()
                }
            }
            
            VStack {
                TextEditor(text: $text)
                    .font(.body)
                    .frame(minHeight: 120)
                    .opacity(text.isEmpty ? 0.85 : 1)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .onTapGesture {
                        isEditing = true
                    }
                
                Spacer()
            }
        }
    }
}
