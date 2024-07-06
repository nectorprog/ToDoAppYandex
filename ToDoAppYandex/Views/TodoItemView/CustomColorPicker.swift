import SwiftUI

struct CustomColorPicker: View {
    @Binding var selectedColor: Color
    @State private var brightness: Double = 1.0
    
    var body: some View {
        VStack {
            HStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(selectedColor)
                    .frame(width: 50, height: 50)
                Text(selectedColor.hexString)
                    .font(.headline)
            }
            .padding()
            
            ColorPalette(selectedColor: $selectedColor)
                .frame(height: 200)
            
            Slider(value: $brightness, in: 0...1)
                .padding()
                .onChange(of: brightness) { newValue in
                    selectedColor = selectedColor.adjustBrightness(to: newValue)
                }
        }
    }
}




