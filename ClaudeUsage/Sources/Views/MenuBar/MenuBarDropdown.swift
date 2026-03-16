import SwiftUI

struct MenuBarDropdown: View {
    @ObservedObject var service = UsageDataService.shared
    @ObservedObject var settings = AppSettings.shared
    @Environment(\.openWindow) private var openWindow

    private var colors: ThemeColors { settings.colors }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                Image(systemName: "sparkle")
                    .foregroundColor(colors.accent)
                Text("Claude Usage")
                    .font(ThemeTypography.heading)
                    .foregroundColor(colors.text)
                Spacer()
                if service.isRefreshing {
                    ProgressView()
                        .scaleEffect(0.6)
                        .frame(width: 16, height: 16)
                } else {
                    Button(action: { Task { await service.refresh() } }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(colors.muted)
                            .font(.system(size: 11))
                    }
                    .buttonStyle(.plain)
                }
            }

            SectionDivider()

            // Quota Section
            if let error = service.quotaError {
                Text(error)
                    .font(ThemeTypography.caption)
                    .foregroundColor(colors.accent)
            } else {
                quotaSection
            }

            SectionDivider()

            // Today's Stats
            SectionHeader(title: "Today")
            StatRow(label: "Messages", value: formatNumber(service.todayStats.messages))
            StatRow(label: "Sessions", value: formatNumber(service.todayStats.sessions))
            StatRow(label: "Tool Calls", value: formatNumber(service.todayStats.toolCalls))
            StatRow(label: "Tokens", value: formatTokens(service.todayStats.tokens))

            SectionDivider()

            // Model Breakdown
            if !service.modelBreakdowns.isEmpty {
                SectionHeader(title: "Models")
                ModelBar(breakdowns: service.modelBreakdowns)
                SectionDivider()
            }

            // Footer
            HStack {
                if let lastUpdated = service.lastUpdated {
                    Text("Updated \(lastUpdated, style: .relative) ago")
                        .font(ThemeTypography.caption)
                        .foregroundColor(colors.muted)
                }
                Spacer()
                Button(action: {
                    openWindow(id: "settings")
                }) {
                    Image(systemName: "gear")
                        .foregroundColor(colors.muted)
                        .font(.system(size: 11))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(12)
        .frame(width: 280)
        .background(colors.background)
        .task {
            if service.lastUpdated == nil {
                await service.refresh()
            }
        }
    }

    private var quotaSection: some View {
        VStack(spacing: 8) {
            ProgressBarView(
                value: Double(service.quota.sessionPercent),
                label: "Session",
                detail: "Resets \(service.quota.sessionResetTime)"
            )
            ProgressBarView(
                value: Double(service.quota.weeklyAllPercent),
                label: "Weekly (all models)",
                detail: "Resets \(service.quota.weeklyAllResetTime)"
            )
            ProgressBarView(
                value: Double(service.quota.weeklySonnetPercent),
                label: "Weekly (Sonnet)",
                detail: "Resets \(service.quota.weeklySonnetResetTime)"
            )
        }
    }
}
