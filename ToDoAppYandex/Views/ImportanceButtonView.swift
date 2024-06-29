import SwiftUI



struct ImportanceButtonView: View {
    struct ImportanceOption {
        var title: String
        var isSelected: Bool
    }

    @State private var options = [
        ImportanceOption(title: "↓", isSelected: false),
        ImportanceOption(title: "НЕТ", isSelected: false),
        ImportanceOption(title: "!!", isSelected: false)
    ]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<options.count, id: \.self) { index in
                Button(action: {
                    selectOption(index: index)
                }) {
                    Text(options[index].title)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(options[index].isSelected ? Color.gray : Color.white)
                        .foregroundColor(Color.black)
                }
                if index < options.count - 1 {
                    Divider()
                        .background(Color.gray)
                }
            }
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        
        
    }

    private func selectOption(index: Int) {
        for i in 0..<options.count {
            options[i].isSelected = (i == index)
        }
    }
}

#Preview {
    ImportanceButtonView()
}


