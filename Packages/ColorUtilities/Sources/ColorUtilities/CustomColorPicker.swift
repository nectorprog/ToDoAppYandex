import SwiftUI

public struct CustomColorPicker: View {
    @Binding public var selectedColor: Color
    @State private var brightness: Double = 1.0
    
    public init(selectedColor: Binding<Color>) {
        self._selectedColor = selectedColor
    }
    
    public var body: some View {
        VStack {
            HStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(selectedColor)
                    .frame(width: 50, height: 50)
                Text(selectedColor.hexString())
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

extension Color {
    func hexString() -> String {
        let components = UIColor(self).cgColor.components
        let r: CGFloat = components?[0] ?? 0.0
        let g: CGFloat = components?[1] ?? 0.0
        let b: CGFloat = components?[2] ?? 0.0
        let hexString = String(format: "#%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255)))
        return hexString
    }
    
    func adjustBrightness(to value: Double) -> Color {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        UIColor(self).getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        return Color(hue: Double(hue), saturation: Double(saturation), brightness: value, opacity: Double(alpha))
    }
}
