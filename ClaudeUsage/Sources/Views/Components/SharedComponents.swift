import SwiftUI

// MARK: - Section Divider

struct SectionDivider: View {
    @ObservedObject private var settings = AppSettings.shared
    @Environment(\.colorScheme) private var colorScheme
    private var colors: ThemeColors { settings.effectiveColors(for: colorScheme) }

    var body: some View {
        Rectangle()
            .fill(colors.muted.opacity(0.2))
            .frame(height: 0.5)
            .padding(.vertical, 2)
    }
}

// MARK: - Stat Row

struct StatRow: View {
    let label: String
    let value: String
    @ObservedObject private var settings = AppSettings.shared
    @Environment(\.colorScheme) private var colorScheme
    private var colors: ThemeColors { settings.effectiveColors(for: colorScheme) }

    var body: some View {
        HStack {
            Text(label)
                .font(ThemeTypography.body)
                .foregroundColor(colors.muted)
            Spacer()
            Text(value)
                .font(ThemeTypography.body)
                .foregroundColor(colors.text)
        }
    }
}

// MARK: - Section Header

struct SectionHeader: View {
    let title: String
    @ObservedObject private var settings = AppSettings.shared
    @Environment(\.colorScheme) private var colorScheme
    private var colors: ThemeColors { settings.effectiveColors(for: colorScheme) }

    var body: some View {
        Text(title.uppercased())
            .font(ThemeTypography.caption)
            .foregroundColor(colors.muted)
            .tracking(1.2)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Model Bar

struct ModelBar: View {
    let breakdowns: [ModelBreakdown]
    @ObservedObject private var settings = AppSettings.shared
    @Environment(\.colorScheme) private var colorScheme
    private var colors: ThemeColors { settings.effectiveColors(for: colorScheme) }

    private func colorForModel(_ name: String) -> Color {
        if name.contains("Opus") { return Color(red: 0.694, green: 0.725, blue: 0.976) }
        if name.contains("Sonnet") { return Color(red: 0.843, green: 0.467, blue: 0.341) }
        if name.contains("Haiku") { return Color(red: 0.298, green: 0.686, blue: 0.314) }
        return colors.muted
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Stacked bar with glass effect
            GeometryReader { geo in
                HStack(spacing: 1) {
                    ForEach(breakdowns) { model in
                        let color = colorForModel(model.displayName)
                        glassModelSegment(color: color, width: max(2, geo.size.width * model.percentage / 100))
                    }
                }
            }
            .frame(height: 10)
            .clipShape(RoundedRectangle(cornerRadius: 5))

            // Legend
            ForEach(breakdowns) { model in
                HStack(spacing: 6) {
                    Circle()
                        .fill(colorForModel(model.displayName))
                        .frame(width: 8, height: 8)
                    Text(model.displayName)
                        .font(ThemeTypography.caption)
                        .foregroundColor(colors.muted)
                    Spacer()
                    Text(formatTokens(model.tokens))
                        .font(ThemeTypography.caption)
                        .foregroundColor(colors.text)
                    Text("(\(Int(model.percentage))%)")
                        .font(ThemeTypography.caption)
                        .foregroundColor(colors.muted)
                }
            }
        }
    }

    @ViewBuilder
    private func glassModelSegment(color: Color, width: CGFloat) -> some View {
        if #available(macOS 26, *) {
            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(width: width)
                .glassEffect(.regular.tint(color), in: .rect(cornerRadius: 2))
        } else {
            RoundedRectangle(cornerRadius: 2)
                .fill(color.opacity(0.85))
                .frame(width: width)
        }
    }
}

// MARK: - Number Formatting

func formatNumber(_ n: Int) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    return formatter.string(from: NSNumber(value: n)) ?? "\(n)"
}

func formatTokens(_ count: Int) -> String {
    if count >= 1_000_000 {
        return String(format: "%.1fM", Double(count) / 1_000_000)
    } else if count >= 1_000 {
        return String(format: "%.1fK", Double(count) / 1_000)
    }
    return "\(count)"
}
