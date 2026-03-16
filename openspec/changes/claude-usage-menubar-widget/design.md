## Context

Claude Code stores usage data locally at `~/.claude/stats-cache.json` (daily activity, token counts by model, lifetime stats) and per-session JSONL files under `~/.claude/projects/`. Live quota data (session %, weekly % with reset times) is only accessible via the `/usage` slash command inside an active Claude Code session, which we can automate with `expect`.

There is no Anthropic API for subscription quota — this app fills that gap by combining local file parsing with automated CLI interaction.

Target: macOS 14+ (Sonoma), required for WidgetKit desktop widgets + SwiftUI MenuBarExtra.

## Goals / Non-Goals

**Goals:**
- Native macOS app with WidgetKit desktop widgets (small, medium, large)
- Menu bar status item with rich dropdown
- Settings window with usage overview and manual refresh
- Claude Code visual design language (dark theme, indigo/coral accents, monospace)
- Open-source distribution via GitHub, Homebrew cask
- Zero configuration needed — auto-detects Claude CLI

**Non-Goals:**
- API key management or Anthropic Admin API integration (future enhancement)
- Windows/Linux support
- Real-time streaming (polling every 5-10 min is sufficient)
- Modifying any Claude CLI data (strictly read-only)

## Decisions

### 1. Native SwiftUI app vs SwiftBar plugin

**Decision**: Native SwiftUI app

**Rationale**: The user wants both desktop widgets AND menu bar icons. WidgetKit requires a host app — we need a native app anyway. SwiftUI's `MenuBarExtra` gives us the menu bar integration for free. A single app covers all three surfaces (widgets, menu bar, settings window).

**Alternative considered**: SwiftBar/xbar plugin — simpler but can't do WidgetKit desktop widgets, limited UI customization for Claude Code design language.

### 2. Data fetching architecture

**Decision**: Background `Process` spawning `expect` script + JSON file reads, coordinated by a shared `UsageDataService`

**Architecture**:
```
UsageDataService (ObservableObject, shared singleton)
  ├── QuotaFetcher: spawns expect → claude /usage → parses ANSI → QuotaData
  ├── StatsFetcher: reads ~/.claude/stats-cache.json → StatsData
  └── Timer: fires every N minutes (configurable, default 10)
       ├── Updates @Published properties
       └── Pushes to WidgetCenter.shared.reloadAllTimelines()
```

**Rationale**: Separation of concerns. The expect-based quota fetch (~8s) is the expensive operation; stats file read is instant. They run independently. WidgetKit gets data via App Group shared UserDefaults/files.

### 3. App Group for widget data sharing

**Decision**: Use App Group container with JSON file for data transfer between main app and widget extension.

**Rationale**: WidgetKit extensions run in a separate process. They can't access the main app's memory. App Group shared container is Apple's recommended approach. We write a `widget-data.json` to the shared container on each refresh; widgets read it in their TimelineProvider.

### 4. Design system

**Decision**: Custom design tokens matching Claude Code CLI aesthetics.

```
Colors:
  - Background: #1A1A2E (deep navy/dark)
  - Surface: #16213E (card background)
  - Primary: #B1B9F9 (indigo/periwinkle — Claude's accent)
  - Accent: #D77757 (coral/orange — Claude's logo)
  - Text: #E0E0E0 (light gray)
  - Muted: #888888 (secondary text)

Typography:
  - Primary: SF Mono (monospace, matches CLI feel)
  - Fallback: Menlo, system monospace

Components:
  - Progress bars with rounded ends, indigo fill
  - Section dividers matching CLI ── style
  - Compact stat rows with label/value alignment
```

### 5. Expect script approach

**Decision**: Bundle a Python expect-like script using `pexpect` library (or pure Python with `subprocess` + pseudo-TTY) rather than system `expect`.

**Rationale**: Python is pre-installed on macOS. Using `pty` + `subprocess` avoids dependency on `expect` binary. The script spawns `claude`, waits for prompt, sends `/usage`, captures output, strips ANSI codes, extracts percentages and reset times, outputs JSON to stdout.

**Alternative considered**: System `expect` — works but requires `/usr/bin/expect` which may not be present on all macOS installs. Python's `pty` module is more portable.

## Risks / Trade-offs

- **[Risk] Claude CLI output format changes** → Mitigation: Version-aware parsing with fallback. Log parse failures. The ANSI stripping + regex approach is resilient to minor formatting changes.
- **[Risk] expect spawn takes ~8 seconds** → Mitigation: Run in background, cache results. Widget shows cached data with "last updated" timestamp. Never blocks UI.
- **[Risk] stats-cache.json may be stale** → Mitigation: Show `lastComputedDate` in UI. This is a CLI limitation, not ours.
- **[Risk] App notarization for distribution** → Mitigation: Sign with Developer ID for direct download. Homebrew cask handles Gatekeeper. Can skip App Store initially.
- **[Trade-off] macOS 14+ only** → Acceptable. WidgetKit desktop widgets require macOS 14 Sonoma. Older macOS users are a small minority of Claude Code users.

## Open Questions

- Should we support multiple Claude accounts / profiles? (defer to v2)
- Should we add notification support for approaching quota limits? (nice-to-have, defer)
