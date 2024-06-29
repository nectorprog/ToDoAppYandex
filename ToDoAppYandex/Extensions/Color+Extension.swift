import SwiftUI

extension Color {
    init?(hex: String) {
        let r, g, b: CGFloat
        let hex = hex.hasPrefix("#") ? String(hex.dropFirst()) : hex

        guard let hexNumber = Int(hex, radix: 16) else {
            return nil
        }

        r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
        g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
        b = CGFloat(hexNumber & 0x0000ff) / 255

        self.init(red: r, green: g, blue: b)
    }
    
    var toHex: String? {
            guard let components = cgColor?.components, components.count >= 3 else {
                return nil
            }

            let r = components[0]
            let g = components[1]
            let b = components[2]

        return String(
            format: "#%02X%02X%02X",
            Int(
                r * 255
            ),
            Int(
                g * 255
            ),
            Int(
                b * 255
            )
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
}
