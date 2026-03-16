import SwiftUI

struct ProgressBarView: View {
    let value: Double
    let label: String
    let detail: String
    @ObservedObject private var settings = AppSettings.shared

    private var colors: ThemeColors { settings.colors }
    private var isWarning: Bool { value >= settings.warningThreshold }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(ThemeTypography.caption)
                    .foregroundColor(colors.muted)
                Spacer()
                Text("\(Int(value))%")
                    .font(ThemeTypography.body)
                    .foregroundColor(isWarning ? colors.accent : colors.text)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // Track
                    RoundedRectangle(cornerRadius: 4)
                        .fill(colors.surface.opacity(0.5))
                        .frame(height: 8)
                    // Fill
                    glassProgressFill(width: max(0, geo.size.width * min(value / 100, 1.0)))
                }
            }
            .frame(height: 8)
            if !detail.isEmpty {
                Text(detail)
                    .font(ThemeTypography.caption)
                    .foregroundColor(colors.muted)
            }
        }
    }

    @ViewBuilder
    private func glassProgressFill(width: CGFloat) -> some View {
        if #available(macOS 26, *) {
            RoundedRectangle(cornerRadius: 4)
                .fill(isWarning ? colors.accent : colors.primary)
                .frame(width: width, height: 8)
                .glassEffect(.regular.tint(isWarning ? colors.accent : colors.primary), in: .rect(cornerRadius: 4))
        } else {
            RoundedRectangle(cornerRadius: 4)
                .fill(
                    LinearGradient(
                        colors: [
                            (isWarning ? colors.accent : colors.primary).opacity(0.8),
                            (isWarning ? colors.accent : colors.primary)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: width, height: 8)
                .shadow(color: (isWarning ? colors.accent : colors.primary).opacity(0.3), radius: 4, y: 0)
        }
    }
}

struct CircularProgressView: View {
    let value: Double
    let label: String
    @ObservedObject private var settings = AppSettings.shared

    private var colors: ThemeColors { settings.colors }
    private var isWarning: Bool { value >= settings.warningThreshold }

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .stroke(colors.surface.opacity(0.5), lineWidth: 6)
                Circle()
                    .trim(from: 0, to: min(value / 100, 1.0))
                    .stroke(
                        isWarning ? colors.accent : colors.primary,
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .shadow(color: (isWarning ? colors.accent : colors.primary).opacity(0.4), radius: 6)
                Text("\(Int(value))%")
                    .font(ThemeTypography.statValue)
                    .foregroundColor(colors.text)
            }
            Text(label)
                .font(ThemeTypography.caption)
                .foregroundColor(colors.muted)
        }
    }
}
