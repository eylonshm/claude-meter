import SwiftUI
import ServiceManagement

struct SettingsWindow: View {
    @State private var selectedTab = 0
    @ObservedObject var settings = AppSettings.shared

    var body: some View {
        TabView(selection: $selectedTab) {
            UsageTab()
                .tabItem { Label("Usage", systemImage: "chart.bar") }
                .tag(0)
            SettingsTab()
                .tabItem { Label("Settings", systemImage: "gear") }
                .tag(1)
        }
        .frame(minWidth: 480, minHeight: 560)
        .background(settings.colors.background)
    }
}

// MARK: - Usage Tab

struct UsageTab: View {
    @ObservedObject var service = UsageDataService.shared
    @ObservedObject var settings = AppSettings.shared

    private var colors: ThemeColors { settings.colors }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header with refresh
                HStack {
                    Text("Usage Overview")
                        .font(ThemeTypography.title)
                        .foregroundColor(colors.text)
                    Spacer()
                    if service.isRefreshing {
                        ProgressView()
                            .scaleEffect(0.7)
                    }
                    Button(action: { Task { await service.refresh() } }) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.clockwise")
                            Text("Refresh")
                        }
                        .font(ThemeTypography.caption)
                        .foregroundColor(colors.primary)
                    }
                    .buttonStyle(.plain)
                    .disabled(service.isRefreshing)
                }

                if let lastUpdated = service.lastUpdated {
                    Text("Last refreshed: \(lastUpdated, style: .relative) ago")
                        .font(ThemeTypography.caption)
                        .foregroundColor(colors.muted)
                }

                SectionDivider()

                // Quota
                if service.quotaError == nil {
                    SectionHeader(title: "Quota")
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
                    SectionDivider()
                }

                // Period Stats
                SectionHeader(title: "Today")
                statsGrid(service.todayStats)
                SectionDivider()

                SectionHeader(title: "This Week")
                statsGrid(service.weekStats)
                SectionDivider()

                SectionHeader(title: "This Month")
                statsGrid(service.monthStats)
                SectionDivider()

                // Model Breakdown
                if !service.modelBreakdowns.isEmpty {
                    SectionHeader(title: "Models")
                    ModelBar(breakdowns: service.modelBreakdowns)
                    SectionDivider()
                }

                // Lifetime
                if let cache = service.statsCache {
                    SectionHeader(title: "Lifetime")
                    StatRow(label: "Total Sessions", value: formatNumber(cache.totalSessions))
                    StatRow(label: "Total Messages", value: formatNumber(cache.totalMessages))
                    if let firstDate = cache.firstSessionDate {
                        StatRow(label: "Member Since", value: String(firstDate.prefix(10)))
                    }
                }
            }
            .padding(20)
        }
        .background(colors.background)
        .task {
            if service.lastUpdated == nil {
                await service.refresh()
            }
        }
    }

    private func statsGrid(_ stats: PeriodStats) -> some View {
        VStack(spacing: 4) {
            StatRow(label: "Messages", value: formatNumber(stats.messages))
            StatRow(label: "Sessions", value: formatNumber(stats.sessions))
            StatRow(label: "Tool Calls", value: formatNumber(stats.toolCalls))
            StatRow(label: "Tokens", value: formatTokens(stats.tokens))
        }
    }
}

// MARK: - Settings Tab

struct SettingsTab: View {
    @ObservedObject var settings = AppSettings.shared
    @ObservedObject var service = UsageDataService.shared

    private var colors: ThemeColors { settings.colors }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Settings")
                    .font(ThemeTypography.title)
                    .foregroundColor(colors.text)

                SectionDivider()

                // General
                SectionHeader(title: "General")

                HStack {
                    Text("Refresh Interval")
                        .font(ThemeTypography.body)
                        .foregroundColor(colors.text)
                    Spacer()
                    Picker("", selection: $settings.refreshInterval) {
                        Text("5 min").tag(5)
                        Text("10 min").tag(10)
                        Text("15 min").tag(15)
                        Text("30 min").tag(30)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 240)
                    .onChange(of: settings.refreshInterval) { _, _ in
                        service.restartTimer()
                    }
                }

                Toggle("Launch at Login", isOn: $settings.launchAtLogin)
                    .font(ThemeTypography.body)
                    .foregroundColor(colors.text)
                    .onChange(of: settings.launchAtLogin) { _, newValue in
                        LoginItemManager.setEnabled(newValue)
                    }

                Toggle("Show Menu Bar Icon", isOn: $settings.showMenuBar)
                    .font(ThemeTypography.body)
                    .foregroundColor(colors.text)

                SectionDivider()

                // Warning Threshold
                SectionHeader(title: "Warning Threshold")
                HStack {
                    Text("\(Int(settings.warningThreshold))%")
                        .font(ThemeTypography.body)
                        .foregroundColor(colors.text)
                        .frame(width: 40)
                    Slider(value: $settings.warningThreshold, in: 50...100, step: 5)
                }

                SectionDivider()

                // Appearance
                SectionHeader(title: "Appearance")

                colorPickerRow("Background", hex: $settings.backgroundHex)
                colorPickerRow("Surface", hex: $settings.surfaceHex)
                colorPickerRow("Primary", hex: $settings.primaryHex)
                colorPickerRow("Accent", hex: $settings.accentHex)
                colorPickerRow("Text", hex: $settings.textHex)
                colorPickerRow("Muted", hex: $settings.mutedHex)
                colorPickerRow("Warning", hex: $settings.warningHex)

                Button("Reset to Defaults") {
                    settings.resetColors()
                }
                .font(ThemeTypography.caption)
                .foregroundColor(colors.accent)
                .buttonStyle(.plain)

                SectionDivider()

                // CLI Path
                SectionHeader(title: "Advanced")
                HStack {
                    Text("Claude CLI Path")
                        .font(ThemeTypography.body)
                        .foregroundColor(colors.text)
                    TextField("Auto-detected", text: $settings.cliPath)
                        .font(ThemeTypography.body)
                        .textFieldStyle(.roundedBorder)
                }
            }
            .padding(20)
        }
        .background(colors.background)
    }

    private func colorPickerRow(_ label: String, hex: Binding<String>) -> some View {
        HStack {
            Text(label)
                .font(ThemeTypography.body)
                .foregroundColor(colors.text)
            Spacer()
            ColorPicker("", selection: Binding(
                get: { Color(hex: hex.wrappedValue) ?? .white },
                set: { hex.wrappedValue = $0.hexString }
            ))
            .labelsHidden()
            .frame(width: 40)
            Text("#\(hex.wrappedValue)")
                .font(ThemeTypography.caption)
                .foregroundColor(colors.muted)
                .frame(width: 60)
        }
    }
}

// MARK: - Login Item Manager

enum LoginItemManager {
    static func setEnabled(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            print("Login item error: \(error)")
        }
    }
}
