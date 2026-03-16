import SwiftUI

// MARK: - Section Divider

struct SectionDivider: View {
    @ObservedObject private var settings = AppSettings.shared

    var body: some View {
        Rectangle()
            .fill(settings.colors.muted.opacity(0.2))
            .frame(height: 0.5)
            .padding(.vertical, 2)
    }
}

// MARK: - Stat Row

struct StatRow: View {
    let label: String
    let value: String
    @ObservedObject private var settings = AppSettings.shared

    var body: some View {
        HStack {
            Text(label)
                .font(ThemeTypography.body)
                .foregroundColor(settings.colors.muted)
            Spacer()
            Text(value)
                .font(ThemeTypography.body)
                .foregroundColor(settings.colors.text)
        }
    }
}

// MARK: - Section Header

struct SectionHeader: View {
    let title: String
    @ObservedObject private var settings = AppSettings.shared

    var body: some View {
        Text(title.uppercased())
            .font(ThemeTypography.caption)
            .foregroundColor(settings.colors.muted)
            .tracking(1.2)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Model Bar

struct ModelBar: View {
    let breakdowns: [ModelBreakdown]
    @ObservedObject private var settings = AppSettings.shared

    private let modelColors: [String: Color] = [
        "Opus": Color(red: 0.694, green: 0.725, blue: 0.976),
        "Sonnet": Color(red: 0.843, green: 0.467, blue: 0.341),
        "Haiku": Color(red: 0.298, green: 0.686, blue: 0.314),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Stacked bar with glass effect
            GeometryReader { geo in
                HStack(spacing: 1) {
                    ForEach(breakdowns) { model in
                        let color = modelColors[model.displayName] ?? settings.colors.muted
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
                        .fill(modelColors[model.displayName] ?? settings.colors.muted)
                        .frame(width: 8, height: 8)
                    Text(model.displayName)
                        .font(ThemeTypography.caption)
                        .foregroundColor(settings.colors.muted)
                    Spacer()
                    Text(formatTokens(model.tokens))
                        .font(ThemeTypography.caption)
                        .foregroundColor(settings.colors.text)
                    Text("(\(Int(model.percentage))%)")
                        .font(ThemeTypography.caption)
                        .foregroundColor(settings.colors.muted)
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
