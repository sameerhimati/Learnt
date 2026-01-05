//
//  Color+Theme.swift
//  Learnt
//

import SwiftUI

extension Color {
    // MARK: - Backgrounds

    static let appBackground = Color("AppBackground")
    static let inputBackground = Color("InputBackground")

    // MARK: - Text

    static let primaryText = Color("PrimaryText")
    static let secondaryText = Color("SecondaryText")

    // MARK: - UI Elements

    static let divider = Color("Divider")
}

// MARK: - Programmatic Colors (fallback if asset catalog not set up)

extension Color {
    static var appBackgroundColor: Color {
        Color(light: Color(hex: "FAFAFA"), dark: Color(hex: "1A1A1A"))
    }

    static var inputBackgroundColor: Color {
        Color(light: Color(hex: "F5F5F5"), dark: Color(hex: "252525"))
    }

    static var primaryTextColor: Color {
        Color(light: Color(hex: "1A1A1A"), dark: Color(hex: "FAFAFA"))
    }

    static var secondaryTextColor: Color {
        Color(light: Color(hex: "6B6B6B"), dark: Color(hex: "9B9B9B"))
    }

    static var dividerColor: Color {
        Color(light: Color(hex: "E8E8E8"), dark: Color(hex: "2A2A2A"))
    }
}

// MARK: - Helpers

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
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    init(light: Color, dark: Color) {
        self.init(uiColor: UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(dark)
            default:
                return UIColor(light)
            }
        })
    }
}
