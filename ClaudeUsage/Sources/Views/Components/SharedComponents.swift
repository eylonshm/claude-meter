import SwiftUI

// MARK: - Section Divider (CLI-style)

struct SectionDivider: View {
    @ObservedObject private var settings = AppSettings.shared

    var body: some View {
        Text(String(repeating: "─", count: 40))
            .font(ThemeTypography.caption)
            .foregroundColor(settings.colors.muted)
            .frame(maxWidth: .infinity, alignment: .leading)
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
        Text(title)
            .font(ThemeTypography.heading)
            .foregroundColor(settings.colors.text)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Model Bar

struct ModelBar: View {
    let breakdowns: [ModelBreakdown]
    @ObservedObject private var settings = AppSettings.shared

    private let modelColors: [String: Color] = [
        "Opus": Color(red: 0.694, green: 0.725, blue: 0.976),   // indigo
        "Sonnet": Color(red: 0.843, green: 0.467, blue: 0.341), // coral
        "Haiku": Color(red: 0.298, green: 0.686, blue: 0.314),  // green
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Stacked bar
            GeometryReader { geo in
                HStack(spacing: 1) {
                    ForEach(breakdowns) { model in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(modelColors[model.displayName] ?? settings.colors.muted)
                            .frame(width: max(2, geo.size.width * model.percentage / 100))
                    }
                }
            }
            .frame(height: 10)
            .clipShape(RoundedRectangle(cornerRadius: 4))

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

    private func formatTokens(_ count: Int) -> String {
        if count >= 1_000_000 {
            return String(format: "%.1fM", Double(count) / 1_000_000)
        } else if count >= 1_000 {
            return String(format: "%.1fK", Double(count) / 1_000)
        }
        return "\(count)"
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
