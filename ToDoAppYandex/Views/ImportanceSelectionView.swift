import SwiftUI

struct ImportanceSelectionView: View {
    @Binding var importance: Importance

    var body: some View {
        HStack(spacing: 0) {
            importanceSelectionButton(icon: "arrow.down", isSelected: importance == .low) {
                importance = .low
            }
            Divider().frame(height: 24)
            importanceSelectionButton(text: "нет", isSelected: importance == .medium) {
                importance = .medium
            }
            Divider().frame(height: 24)
            importanceSelectionButton(icon: "exclamationmark.2", isSelected: importance == .high) {
                importance = .high
            }
        }
//        .background(Color.bElevated)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    @ViewBuilder
    private func importanceSelectionButton(icon: String? = nil, text: String? = nil, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                if let icon = icon {
                    Image(systemName: icon)
                }
                if let text = text {
                    Text(text)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isSelected ? Color.bElevated : Color.sOverlay)
            .foregroundColor(isSelected ? .primary : .gray)
        }
    }
}

struct ImportanceSelectionView_Previews: PreviewProvider {
    @State static var importance: Importance = .medium

    static var previews: some View {
        ImportanceSelectionView(importance: $importance)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
