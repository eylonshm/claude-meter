import Foundation

// MARK: - Stats Cache Models (from ~/.claude/stats-cache.json)

struct StatsCache: Codable {
    let version: Int
    let lastComputedDate: String
    let dailyActivity: [DailyActivity]
    let dailyModelTokens: [DailyModelTokens]
    let modelUsage: [String: ModelUsage]
    let totalSessions: Int
    let totalMessages: Int
    let longestSession: LongestSession?
    let firstSessionDate: String?
    let hourCounts: [String: Int]?
}

struct DailyActivity: Codable {
    let date: String
    let messageCount: Int
    let sessionCount: Int
    let toolCallCount: Int
}

struct DailyModelTokens: Codable {
    let date: String
    let tokensByModel: [String: Int]
}

struct ModelUsage: Codable {
    let inputTokens: Int
    let outputTokens: Int
    let cacheReadInputTokens: Int
    let cacheCreationInputTokens: Int
}

struct LongestSession: Codable {
    let sessionId: String
    let duration: Int
    let messageCount: Int
    let timestamp: String
}

// MARK: - Quota Data (from /usage command)

struct QuotaData: Codable, Equatable {
    var sessionPercent: Int
    var sessionResetTime: String
    var weeklyAllPercent: Int
    var weeklyAllResetTime: String
    var weeklySonnetPercent: Int
    var weeklySonnetResetTime: String

    static let empty = QuotaData(
        sessionPercent: 0, sessionResetTime: "—",
        weeklyAllPercent: 0, weeklyAllResetTime: "—",
        weeklySonnetPercent: 0, weeklySonnetResetTime: "—"
    )
}

// MARK: - Derived Stats

struct PeriodStats {
    var messages: Int = 0
    var sessions: Int = 0
    var toolCalls: Int = 0
    var tokens: Int = 0
}

struct ModelBreakdown: Identifiable {
    let id = UUID()
    let name: String
    let displayName: String
    let tokens: Int
    let percentage: Double
}

// MARK: - Widget Shared Data

struct WidgetData: Codable {
    let quota: QuotaData
    let todayMessages: Int
    let todaySessions: Int
    let todayToolCalls: Int
    let todayTokens: Int
    let modelBreakdowns: [WidgetModelBreakdown]
    let lastUpdated: Date
    let warningThreshold: Double
}

struct WidgetModelBreakdown: Codable, Identifiable {
    var id: String { name }
    let name: String
    let displayName: String
    let tokens: Int
    let percentage: Double
}

// MARK: - App Group Constants

enum AppConstants {
    static let appGroupIdentifier = "group.com.claudeusage.shared"
    static let widgetDataFilename = "widget-data.json"
    static let widgetKind = "ClaudeUsageWidget"
}

// MARK: - Model Name Helpers

extension String {
    var cleanModelName: String {
        if self.contains("opus") { return "Opus" }
        if self.contains("sonnet") { return "Sonnet" }
        if self.contains("haiku") { return "Haiku" }
        return self
    }

    var modelSortOrder: Int {
        if self.contains("opus") { return 0 }
        if self.contains("sonnet") { return 1 }
        if self.contains("haiku") { return 2 }
        return 3
    }
}
