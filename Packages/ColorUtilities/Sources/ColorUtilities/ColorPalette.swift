import SwiftUI

public struct ColorPalette: View {
    @Binding public var selectedColor: Color
    
    public init(selectedColor: Binding<Color>) {
        self._selectedColor = selectedColor
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                LinearGradient(gradient: Gradient(colors: [.red, .yellow, .green, .blue, .purple, .red]), startPoint: .leading, endPoint: .trailing)
                
                Color.white.blendMode(.multiply)
                
                Color.black.opacity(0.5).blendMode(.multiply)
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let x = value.location.x / geometry.size.width
                        let y = 1 - (value.location.y / geometry.size.height)
                        selectedColor = Color(hue: x, saturation: y, brightness: 1)
                    }
            )
        }
        .cornerRadius(12)
    }
}
