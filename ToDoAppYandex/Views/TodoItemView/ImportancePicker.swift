import SwiftUI

struct ImportancePicker: View {
    @Binding var importance: Importance
    
    var body: some View {
        HStack {
            Text("Важность")
            Spacer()
            Picker("", selection: $importance) {
                Image(systemName: "arrow.down")
                    .tag(Importance.low)
                Text("нет")
                    .tag(Importance.medium)
                Text("‼️")
                    .tag(Importance.high)
            }
            .pickerStyle(SegmentedPickerStyle())
            .frame(width: 150)
        }
    }
}

#Preview {
    ImportancePicker(importance: .constant(.medium))
}
