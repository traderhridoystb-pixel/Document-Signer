import SwiftUI

// MARK: - Brand Colors
enum SignerColors {
    // Primary brand color - Deep Electric Blue
    static let primary = Color(hex: "2563EB")
    static let primaryDark = Color(hex: "1D4ED8")
    static let primaryLight = Color(hex: "3B82F6")
    static let primaryUltraLight = Color(hex: "DBEAFE")

    // Secondary - Rich Indigo
    static let secondary = Color(hex: "4F46E5")
    static let secondaryLight = Color(hex: "6366F1")

    // Accent - Vibrant Emerald for CTAs
    static let accent = Color(hex: "10B981")
    static let accentDark = Color(hex: "059669")

    // Semantic colors
    static let success = Color(hex: "22C55E")
    static let warning = Color(hex: "F59E0B")
    static let error = Color(hex: "EF4444")
    static let info = Color(hex: "3B82F6")

    // Neutral palette
    static let backgroundPrimary = Color("BackgroundPrimary", bundle: nil)
    static let backgroundSecondary = Color("BackgroundSecondary", bundle: nil)
    static let backgroundTertiary = Color("BackgroundTertiary", bundle: nil)

    static let textPrimary = Color("TextPrimary", bundle: nil)
    static let textSecondary = Color("TextSecondary", bundle: nil)
    static let textTertiary = Color("TextTertiary", bundle: nil)

    // Fallback neutral colors
    static let neutral50 = Color(hex: "FAFAFA")
    static let neutral100 = Color(hex: "F5F5F5")
    static let neutral200 = Color(hex: "E5E5E5")
    static let neutral300 = Color(hex: "D4D4D4")
    static let neutral400 = Color(hex: "A3A3A3")
    static let neutral500 = Color(hex: "737373")
    static let neutral600 = Color(hex: "525252")
    static let neutral700 = Color(hex: "404040")
    static let neutral800 = Color(hex: "262626")
    static let neutral900 = Color(hex: "171717")

    // Gradient presets
    static let primaryGradient = LinearGradient(
        colors: [primary, secondary],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let accentGradient = LinearGradient(
        colors: [accent, Color(hex: "06B6D4")],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let premiumGradient = LinearGradient(
        colors: [Color(hex: "F59E0B"), Color(hex: "EF4444"), Color(hex: "EC4899")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let darkOverlayGradient = LinearGradient(
        colors: [Color.black.opacity(0), Color.black.opacity(0.6)],
        startPoint: .top,
        endPoint: .bottom
    )
}

// MARK: - Typography
enum SignerTypography {
    static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
    static let title1 = Font.system(size: 28, weight: .bold, design: .rounded)
    static let title2 = Font.system(size: 22, weight: .bold, design: .rounded)
    static let title3 = Font.system(size: 20, weight: .semibold, design: .rounded)
    static let headline = Font.system(size: 17, weight: .semibold, design: .rounded)
    static let body = Font.system(size: 17, weight: .regular, design: .default)
    static let bodyMedium = Font.system(size: 17, weight: .medium, design: .default)
    static let callout = Font.system(size: 16, weight: .regular, design: .default)
    static let subheadline = Font.system(size: 15, weight: .regular, design: .default)
    static let footnote = Font.system(size: 13, weight: .regular, design: .default)
    static let caption1 = Font.system(size: 12, weight: .regular, design: .default)
    static let caption2 = Font.system(size: 11, weight: .regular, design: .default)

    static let displayLarge = Font.system(size: 42, weight: .heavy, design: .rounded)
    static let displayMedium = Font.system(size: 36, weight: .bold, design: .rounded)
    static let priceTag = Font.system(size: 48, weight: .heavy, design: .rounded)
}

// MARK: - Spacing
enum SignerSpacing {
    static let xxxs: CGFloat = 2
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 20
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
    static let xxxl: CGFloat = 40
    static let xxxxl: CGFloat = 48
}

// MARK: - Corner Radius
enum SignerRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let xxl: CGFloat = 24
    static let full: CGFloat = 999
}

// MARK: - Shadows
enum SignerShadow {
    static func small(_ scheme: ColorScheme) -> some View {
        Color.black.opacity(scheme == .dark ? 0.3 : 0.08)
    }

    static let smallRadius: CGFloat = 4
    static let mediumRadius: CGFloat = 8
    static let largeRadius: CGFloat = 16
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
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
}
