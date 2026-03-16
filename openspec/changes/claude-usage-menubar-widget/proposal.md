## Why

Claude Code users have no persistent, at-a-glance way to monitor their usage quota and activity outside of an active CLI session. The only way to check quota is running `/usage` inside Claude Code, which requires context-switching. A native macOS app with desktop widgets, menu bar integration, and a settings UI would let users passively monitor their Claude usage without interrupting their workflow.

## What Changes

- Introduce a native macOS SwiftUI app that reads Claude Code local data (`~/.claude/stats-cache.json`, session JSONL files) and extracts live quota data via `expect` + `claude /usage`
- Provide WidgetKit desktop widgets (small, medium, large) showing quota percentages and usage stats
- Provide a menu bar icon with a dropdown showing live quota, daily/weekly stats, and model breakdown
- Provide a settings window for configuration (refresh interval, display preferences) that also shows full usage details with a manual refresh button
- All UI follows Claude Code's visual design language (dark theme, indigo/coral accents, monospace typography)

## Capabilities

### New Capabilities
- `data-collection`: Background service that reads local Claude CLI files and spawns `expect` sessions to extract live quota data from `/usage`
- `desktop-widgets`: WidgetKit widgets (small/medium/large) displaying quota progress bars, usage stats, and model breakdowns
- `menubar-integration`: macOS menu bar status item with rich dropdown showing live quota, stats, and quick actions
- `settings-ui`: Configuration window with usage overview, refresh controls, and display preferences
- `design-system`: Claude Code-inspired visual design tokens — colors, typography, component styles

### Modified Capabilities

_(none — greenfield project)_

## Impact

- New standalone macOS app (SwiftUI, requires macOS 14+)
- Depends on Claude Code CLI being installed and authenticated
- Reads `~/.claude/` directory (read-only)
- Spawns short-lived `expect` processes for quota data
- Distribution via GitHub releases, Homebrew cask, and potentially SwiftBar/xbar plugin directory
