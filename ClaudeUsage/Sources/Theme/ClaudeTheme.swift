import SwiftUI

// MARK: - Theme Colors

struct ThemeColors {
    var background: Color
    var surface: Color
    var primary: Color
    var accent: Color
    var text: Color
    var muted: Color
    var success: Color
    var warning: Color

    static let defaults = ThemeColors(
        background: Color(red: 0.102, green: 0.102, blue: 0.180),  // #1A1A2E
        surface: Color(red: 0.086, green: 0.129, blue: 0.243),     // #16213E
        primary: Color(red: 0.694, green: 0.725, blue: 0.976),     // #B1B9F9
        accent: Color(red: 0.843, green: 0.467, blue: 0.341),      // #D77757
        text: Color(red: 0.878, green: 0.878, blue: 0.878),        // #E0E0E0
        muted: Color(red: 0.533, green: 0.533, blue: 0.533),       // #888888
        success: Color(red: 0.298, green: 0.686, blue: 0.314),     // #4CAF50
        warning: Color(red: 1.0, green: 0.596, blue: 0.0)          // #FF9800
    )
}

// MARK: - Theme Typography

struct ThemeTypography {
    static let title = Font.custom("SF Mono", size: 16).weight(.bold)
    static let heading = Font.custom("SF Mono", size: 13).weight(.semibold)
    static let body = Font.custom("SF Mono", size: 12)
    static let caption = Font.custom("SF Mono", size: 10)
    static let statValue = Font.custom("SF Mono", size: 20).weight(.bold)
    static let menuBarValue = Font.custom("SF Mono", size: 11).weight(.medium)
}

// MARK: - Glass Helpers

struct GlassBackground: ViewModifier {
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        if #available(macOS 26, *) {
            content
                .glassEffect(.regular, in: .rect(cornerRadius: cornerRadius))
        } else {
            content
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius))
        }
    }
}

struct GlassCard: ViewModifier {
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        if #available(macOS 26, *) {
            content
                .padding(12)
                .glassEffect(.regular, in: .rect(cornerRadius: cornerRadius))
        } else {
            content
                .padding(12)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                )
        }
    }
}

struct InteractiveGlass: ViewModifier {
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        if #available(macOS 26, *) {
            content
                .glassEffect(.regular.interactive(), in: .rect(cornerRadius: cornerRadius))
        } else {
            content
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(Color.white.opacity(0.15), lineWidth: 0.5)
                )
        }
    }
}

extension View {
    func glassBackground(cornerRadius: CGFloat = 16) -> some View {
        modifier(GlassBackground(cornerRadius: cornerRadius))
    }

    func glassCard(cornerRadius: CGFloat = 12) -> some View {
        modifier(GlassCard(cornerRadius: cornerRadius))
    }

    func interactiveGlass(cornerRadius: CGFloat = 8) -> some View {
        modifier(InteractiveGlass(cornerRadius: cornerRadius))
    }
}

// MARK: - App Settings

final class AppSettings: ObservableObject {
    static let shared = AppSettings()

    @AppStorage("refreshInterval") var refreshInterval: Int = 10
    @AppStorage("launchAtLogin") var launchAtLogin: Bool = false
    @AppStorage("showMenuBar") var showMenuBar: Bool = true
    @AppStorage("warningThreshold") var warningThreshold: Double = 80
    @AppStorage("cliPath") var cliPath: String = ""

    // Custom colors stored as hex strings
    @AppStorage("color_background") var backgroundHex: String = "1A1A2E"
    @AppStorage("color_surface") var surfaceHex: String = "16213E"
    @AppStorage("color_primary") var primaryHex: String = "B1B9F9"
    @AppStorage("color_accent") var accentHex: String = "D77757"
    @AppStorage("color_text") var textHex: String = "E0E0E0"
    @AppStorage("color_muted") var mutedHex: String = "888888"
    @AppStorage("color_warning") var warningHex: String = "FF9800"

    var colors: ThemeColors {
        ThemeColors(
            background: Color(hex: backgroundHex) ?? ThemeColors.defaults.background,
            surface: Color(hex: surfaceHex) ?? ThemeColors.defaults.surface,
            primary: Color(hex: primaryHex) ?? ThemeColors.defaults.primary,
            accent: Color(hex: accentHex) ?? ThemeColors.defaults.accent,
            text: Color(hex: textHex) ?? ThemeColors.defaults.text,
            muted: Color(hex: mutedHex) ?? ThemeColors.defaults.muted,
            success: ThemeColors.defaults.success,
            warning: Color(hex: warningHex) ?? ThemeColors.defaults.warning
        )
    }

    func resetColors() {
        backgroundHex = "1A1A2E"
        surfaceHex = "16213E"
        primaryHex = "B1B9F9"
        accentHex = "D77757"
        textHex = "E0E0E0"
        mutedHex = "888888"
        warningHex = "FF9800"
    }
}

// MARK: - Color Hex Extension

extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        guard hex.count == 6 else { return nil }
        var rgbValue: UInt64 = 0
        guard Scanner(string: hex).scanHexInt64(&rgbValue) else { return nil }
        self.init(
            red: Double((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: Double((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: Double(rgbValue & 0x0000FF) / 255.0
        )
    }

    var hexString: String {
        guard let components = NSColor(self).usingColorSpace(.sRGB)?.cgColor.components,
              components.count >= 3 else { return "000000" }
        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)
        return String(format: "%02X%02X%02X", r, g, b)
    }
}
