## ADDED Requirements

### Requirement: Small widget
The system SHALL provide a small WidgetKit widget showing the most critical quota metric — weekly usage (all models) as a circular progress ring with percentage text in the center and "Weekly" label below.

#### Scenario: Quota data available
- **WHEN** the small widget renders with quota data
- **THEN** it displays a circular progress ring filled to the weekly_all_percent value, the percentage as large centered text, and "Weekly Quota" label below

#### Scenario: No data available
- **WHEN** widget data is empty or stale (>30 minutes)
- **THEN** it displays a dimmed ring with "—" and "Open app to sync" text

### Requirement: Medium widget
The system SHALL provide a medium WidgetKit widget showing all three quota bars (session, weekly all, weekly Sonnet) as horizontal progress bars with percentages and reset times, plus today's message and session count.

#### Scenario: Full data available
- **WHEN** the medium widget renders with quota and stats data
- **THEN** it displays three labeled horizontal progress bars (Session, Weekly, Sonnet), each with percent and reset time, plus a compact row showing today's messages and sessions

#### Scenario: Partial data (stats only)
- **WHEN** quota data is unavailable but stats are available
- **THEN** it displays "Quota unavailable" in the quota section and shows today's stats normally

### Requirement: Large widget
The system SHALL provide a large WidgetKit widget showing quota bars, today's stats (messages, sessions, tool calls, tokens), and a model breakdown bar chart showing token distribution across models.

#### Scenario: Full data available
- **WHEN** the large widget renders with all data
- **THEN** it displays quota progress bars, today's stats grid, and a horizontal stacked bar showing model token distribution with legend (color-coded per model)

### Requirement: Widget design
All widgets SHALL use the Claude Code design system — dark background (#1A1A2E), indigo progress fills (#B1B9F9), coral accents (#D77757), SF Mono typography, and rounded corners matching system widget style.

#### Scenario: Visual consistency
- **WHEN** any widget renders
- **THEN** it uses the defined color palette, SF Mono font, and matches the Claude Code CLI aesthetic
