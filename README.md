# Claude Usage Widget

A native macOS app that shows your Claude Code usage and quota data in desktop widgets, menu bar, and a settings window — all styled to match the Claude Code CLI aesthetic.

![macOS 14+](https://img.shields.io/badge/macOS-14%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![License](https://img.shields.io/badge/License-MIT-green)

## Features

### Menu Bar
- Compact weekly quota percentage always visible in the menu bar
- Rich dropdown panel with quota progress bars, today's stats, and model breakdown
- Warning color when usage exceeds configurable threshold (default: 80%)

### Desktop Widgets
- **Small**: Circular progress ring showing weekly quota
- **Medium**: Three quota bars + today's message/session count
- **Large**: Full dashboard with quota, stats, model distribution

### Settings Window
- **Usage tab**: Comprehensive view of all quota data, period stats, model breakdown, lifetime totals
- **Settings tab**: Refresh interval, launch at login, menu bar visibility, warning threshold, full color customization

### Design
- Claude Code CLI-inspired dark theme (fully customizable)
- SF Mono typography throughout
- CLI-style section dividers
- Indigo progress bars, coral warning accents

## How It Works

The app reads usage data from two sources:

1. **`~/.claude/stats-cache.json`** — Local stats cache maintained by Claude Code (daily activity, token counts by model, lifetime stats)
2. **`claude /usage` command** — Live quota data (session %, weekly % for all models, weekly % Sonnet only, reset times) extracted by spawning a brief CLI session

No API keys, no OAuth, no cloud services. Everything is local.

## Requirements

- **macOS 14 (Sonoma)** or later
- **Claude Code CLI** installed and authenticated (`brew install claude` or download from [claude.ai/code](https://claude.ai/code))
- **Xcode 15+** (to build from source)

## Installation

### Build from Source

```bash
git clone https://github.com/eylonshm/claude-usage-widget.git
cd claude-usage-widget
xcodegen generate
open ClaudeUsage.xcodeproj
```

Then build and run from Xcode (Cmd+R).

### Adding Desktop Widgets

1. Right-click on your desktop
2. Select "Edit Widgets..."
3. Search for "Claude Usage"
4. Drag a widget (Small, Medium, or Large) to your desktop

## Configuration

Open the Settings window from the menu bar dropdown (gear icon):

- **Refresh Interval**: 5, 10, 15, or 30 minutes
- **Warning Threshold**: Percentage at which progress bars turn coral (default: 80%)
- **Colors**: Full customization of background, surface, primary, accent, text, muted, and warning colors
- **Launch at Login**: Auto-start on login
- **CLI Path**: Override auto-detected Claude CLI path

## Project Structure

```
ClaudeUsage/
  Sources/
    App/           -- Main app entry point (MenuBarExtra + Settings window)
    Models/        -- Data models (StatsCache, QuotaData, WidgetData)
    Services/      -- Data fetching (StatsFetcher, QuotaFetcher, UsageDataService)
    Views/
      Components/  -- Reusable UI (ProgressBar, StatRow, SectionDivider, ModelBar)
      MenuBar/     -- Menu bar dropdown panel
      Settings/    -- Settings window (Usage + Settings tabs)
    Theme/         -- Design system (colors, typography, settings)
ClaudeUsageWidget/
  Sources/         -- WidgetKit extension (Small, Medium, Large widgets)
```

## Tech Stack

- **SwiftUI** — All UI
- **WidgetKit** — Desktop widgets
- **MenuBarExtra** — Menu bar integration
- **PTY/Process** — CLI interaction for quota data
- **App Groups** — Data sharing between app and widget extension
- **XcodeGen** — Project generation from `project.yml`

## License

MIT
