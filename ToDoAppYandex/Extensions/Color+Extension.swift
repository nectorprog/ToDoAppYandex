import Foundation
import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    static let bElevated = Color("backElevated")
    static let biPrimary = Color("backIosPrimary")
    static let bPrimary = Color("backPrimary")
    static let bSecondary = Color("backSecondary")
    
    static let cBlue = Color("colorBlue")
    static let cGray = Color("colorGray")
    static let cGrayLight = Color("colorGrayLight")
    static let cGreen = Color("colorGreen")
    static let cRed = Color("colorRed")
    static let cWhite = Color("colorWhite")
    
    static let lDisable = Color("labelDisable")
    static let lPrimary = Color("labelPrimary")
    static let lSecondary = Color("labelSecondary")
    static let lTertiary = Color("labelTertiary")
    static let sNavBarBlur = Color("supportNavBarBlur")
    static let sOverlay = Color("supportOverlay")
    static let sSeparatior = Color("supportSeparator")
    
    var hexString: String {
        let components = UIColor(self).cgColor.components
        let r: CGFloat = components?[0] ?? 0.0
        let g: CGFloat = components?[1] ?? 0.0
        let b: CGFloat = components?[2] ?? 0.0
        let hexString = String.init(format: "#%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255)))
        return hexString
    }
    
    func adjustBrightness(to value: Double) -> Color {
        let uiColor = UIColor(self)
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return Color(hue: Double(h), saturation: Double(s), brightness: value, opacity: Double(a))
    }
}
