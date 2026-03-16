import Foundation
import Combine
import WidgetKit

@MainActor
final class UsageDataService: ObservableObject {
    static let shared = UsageDataService()

    // Published state
    @Published var quota: QuotaData = .empty
    @Published var statsCache: StatsCache?
    @Published var todayStats: PeriodStats = PeriodStats()
    @Published var weekStats: PeriodStats = PeriodStats()
    @Published var monthStats: PeriodStats = PeriodStats()
    @Published var modelBreakdowns: [ModelBreakdown] = []
    @Published var lastUpdated: Date?
    @Published var isRefreshing: Bool = false
    @Published var quotaError: String?
    @Published var statsError: String?

    private let statsFetcher = StatsFetcher()
    private let quotaFetcher = QuotaFetcher()
    private var refreshTimer: Timer?
    private let settings = AppSettings.shared

    private init() {
        startTimer()
    }

    // MARK: - Refresh

    func refresh() async {
        guard !isRefreshing else { return }
        isRefreshing = true

        async let statsResult: Void = fetchStats()
        async let quotaResult: Void = fetchQuota()

        await statsResult
        await quotaResult

        lastUpdated = Date()
        isRefreshing = false

        writeWidgetData()
        WidgetCenter.shared.reloadAllTimelines()
    }

    private func fetchStats() async {
        do {
            let cache = try await statsFetcher.fetch()
            self.statsCache = cache
            self.todayStats = statsFetcher.computeToday(from: cache)
            self.weekStats = statsFetcher.computeThisWeek(from: cache)
            self.monthStats = statsFetcher.computeThisMonth(from: cache)
            self.modelBreakdowns = statsFetcher.computeModelBreakdowns(from: cache)
            self.statsError = nil
        } catch {
            self.statsError = error.localizedDescription
        }
    }

    private func fetchQuota() async {
        let logFile = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".claude-usage-debug.log")
        func log(_ msg: String) {
            let line = "[\(Date())] \(msg)\n"
            if let data = line.data(using: .utf8) {
                if FileManager.default.fileExists(atPath: logFile.path) {
                    if let fh = try? FileHandle(forWritingTo: logFile) {
                        fh.seekToEndOfFile()
                        fh.write(data)
                        fh.closeFile()
                    }
                } else {
                    try? data.write(to: logFile)
                }
            }
        }

        log("Starting quota fetch...")
        do {
            let quotaData = try await quotaFetcher.fetch()
            self.quota = quotaData
            self.quotaError = nil
            log("OK: session=\(quotaData.sessionPercent)% weekly=\(quotaData.weeklyAllPercent)% sonnet=\(quotaData.weeklySonnetPercent)%")
        } catch {
            self.quotaError = error.localizedDescription
            log("ERROR: \(error)")
        }
    }

    // MARK: - Timer

    func startTimer() {
        refreshTimer?.invalidate()
        let interval = TimeInterval(settings.refreshInterval * 60)
        refreshTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.refresh()
            }
        }
    }

    func restartTimer() {
        startTimer()
    }

    // MARK: - Widget Data Sharing

    private func writeWidgetData() {
        guard let containerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: AppConstants.appGroupIdentifier
        ) else { return }

        let widgetBreakdowns = modelBreakdowns.map {
            WidgetModelBreakdown(name: $0.name, displayName: $0.displayName, tokens: $0.tokens, percentage: $0.percentage)
        }

        let data = WidgetData(
            quota: quota,
            todayMessages: todayStats.messages,
            todaySessions: todayStats.sessions,
            todayToolCalls: todayStats.toolCalls,
            todayTokens: todayStats.tokens,
            modelBreakdowns: widgetBreakdowns,
            lastUpdated: Date(),
            warningThreshold: settings.warningThreshold
        )

        let fileURL = containerURL.appendingPathComponent(AppConstants.widgetDataFilename)
        if let encoded = try? JSONEncoder().encode(data) {
            try? encoded.write(to: fileURL)
        }
    }
}
