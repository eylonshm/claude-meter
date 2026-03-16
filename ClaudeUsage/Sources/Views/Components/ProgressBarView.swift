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
                    RoundedRectangle(cornerRadius: 4)
                        .fill(colors.surface)
                        .frame(height: 8)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(isWarning ? colors.accent : colors.primary)
                        .frame(width: max(0, geo.size.width * min(value / 100, 1.0)), height: 8)
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
                    .stroke(colors.surface, lineWidth: 6)
                Circle()
                    .trim(from: 0, to: min(value / 100, 1.0))
                    .stroke(
                        isWarning ? colors.accent : colors.primary,
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
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
