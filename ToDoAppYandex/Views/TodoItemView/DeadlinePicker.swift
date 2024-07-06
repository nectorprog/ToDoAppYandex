import SwiftUI

struct DeadlinePicker: View {
    @Binding var isOn: Bool
    @Binding var date: Date
    @Binding var showingCalendar: Bool
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    
    var body: some View {
        VStack {
            HStack {
                Text("Сделать до")
                Spacer()
                Toggle("", isOn: $isOn)
                    .onChange(of: isOn) { newValue in
                        if newValue {
                            date = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
                            withAnimation(.easeInOut) {
                                showingCalendar = true
                            }
                        } else {
                            withAnimation(.easeInOut) {
                                showingCalendar = false
                            }
                        }
                    }
            }
            
            if isOn {
                HStack {
                    Button(action: {
                        withAnimation(.easeInOut) {
                            showingCalendar.toggle()
                        }
                    }) {
                        Text(dateFormatter.string(from: date))
                            .foregroundColor(.blue)
                    }
                    Spacer()
                }
            }
        }
    }
}
