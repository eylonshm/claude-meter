## 1. Project Setup

- [ ] 1.1 Create Xcode project structure with SwiftUI app, widget extension, and App Group entitlement
- [ ] 1.2 Set up App Group container identifier and shared data path
- [ ] 1.3 Configure build targets (main app + widget extension) with macOS 14+ deployment target

## 2. Design System

- [ ] 2.1 Create ClaudeTheme with color palette (background, surface, primary, accent, text, muted, success, warning)
- [ ] 2.2 Create typography definitions (SF Mono at all size variants)
- [ ] 2.3 Build ProgressBarView component (rounded, color-aware for >80% threshold)
- [ ] 2.4 Build SectionDivider component (CLI-style ──── line)
- [ ] 2.5 Build StatRow component (label/value with consistent alignment)

## 3. Data Models

- [ ] 3.1 Define StatsData model matching stats-cache.json schema (dailyActivity, dailyModelTokens, modelUsage, totals)
- [ ] 3.2 Define QuotaData model (session_percent, weekly_all_percent, weekly_sonnet_percent, reset times)
- [ ] 3.3 Define WidgetData model for App Group shared container (combines quota + derived stats)
- [ ] 3.4 Define AppSettings model (refresh interval, launch at login, show menu bar, CLI path)

## 4. Data Collection

- [ ] 4.1 Implement StatsFetcher — reads and parses ~/.claude/stats-cache.json
- [ ] 4.2 Implement QuotaFetcher — spawns PTY process with claude CLI, sends /usage, parses ANSI output to extract percentages and reset times
- [ ] 4.3 Implement derived metrics computation (today, this week, this month aggregations from dailyActivity)
- [ ] 4.4 Implement UsageDataService (ObservableObject singleton) with timer-based refresh, manual refresh, and App Group data writing
- [ ] 4.5 Handle error states (CLI not found, not authenticated, parse failures, missing stats file)

## 5. Menu Bar Integration

- [ ] 5.1 Create MenuBarExtra with compact percentage display and icon
- [ ] 5.2 Build menu bar dropdown panel with quota section (3 progress bars + reset times)
- [ ] 5.3 Add today's stats section to dropdown (messages, sessions, tool calls, tokens)
- [ ] 5.4 Add model breakdown section to dropdown
- [ ] 5.5 Add footer with last updated time, refresh button, and settings gear icon
- [ ] 5.6 Implement high-usage warning styling (coral color when >80%)

## 6. Settings Window

- [ ] 6.1 Create settings window with tabbed layout (Usage + Settings tabs)
- [ ] 6.2 Build Usage tab with comprehensive stats display (quota, period stats, model breakdown, lifetime)
- [ ] 6.3 Add manual refresh button with loading spinner to Usage tab
- [ ] 6.4 Build Settings tab (refresh interval picker, launch at login toggle, menu bar toggle, CLI path)
- [ ] 6.5 Implement launch at login via SMAppService
- [ ] 6.6 Persist settings via UserDefaults

## 7. Desktop Widgets

- [ ] 7.1 Create widget extension target with App Group access
- [ ] 7.2 Implement TimelineProvider that reads from shared App Group container
- [ ] 7.3 Build small widget — circular progress ring with weekly quota percentage
- [ ] 7.4 Build medium widget — three quota bars + today's message/session count
- [ ] 7.5 Build large widget — quota bars, today's stats grid, model distribution bar
- [ ] 7.6 Apply Claude Code design system to all widget views

## 8. Polish and Distribution

- [ ] 8.1 Add app icon (Claude-inspired design)
- [ ] 8.2 Handle first-launch experience (detect CLI, show setup guidance)
- [ ] 8.3 Write README with screenshots, installation instructions, and requirements
- [ ] 8.4 Create Homebrew cask formula
- [ ] 8.5 Set up GitHub Actions for building and releasing signed DMG
