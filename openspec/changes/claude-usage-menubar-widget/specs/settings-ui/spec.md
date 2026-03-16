## ADDED Requirements

### Requirement: Settings window
The system SHALL provide a settings window accessible from the menu bar dropdown. The window SHALL have a tabbed layout with "Usage" and "Settings" tabs.

#### Scenario: Open settings
- **WHEN** the user opens the settings window
- **THEN** it displays as a standard macOS window with the Usage tab selected by default

### Requirement: Usage tab
The Usage tab SHALL display a comprehensive usage overview including all three quota bars with percentages and reset times, today's stats, this week's stats, this month's stats, per-model token breakdown with percentages, lifetime totals (total sessions, total messages, member since date), and a manual refresh button.

#### Scenario: Full usage view
- **WHEN** the Usage tab is displayed with all data available
- **THEN** it shows quota section, period stats (today/week/month), model breakdown, and lifetime stats in a scrollable layout

#### Scenario: Manual refresh
- **WHEN** the user clicks the refresh button on the Usage tab
- **THEN** the button shows a spinning indicator, both fetchers run, data updates in-place, and the button returns to normal state with updated "last refreshed" timestamp

### Requirement: Settings tab
The Settings tab SHALL provide configuration for: refresh interval (5, 10, 15, 30 minutes), launch at login toggle, show menu bar icon toggle, Claude CLI path override (auto-detected by default), warning threshold percentage (default 80%), and an Appearance section with color pickers for all theme colors (background, surface, primary, accent, text, muted, warning) with a "Reset to defaults" button.

#### Scenario: Change refresh interval
- **WHEN** the user selects a different refresh interval
- **THEN** the timer resets to the new interval immediately

#### Scenario: Toggle launch at login
- **WHEN** the user enables launch at login
- **THEN** the app registers as a login item via SMAppService

#### Scenario: Toggle menu bar icon
- **WHEN** the user disables the menu bar icon
- **THEN** the status item is hidden (app still runs for widget data)

### Requirement: Settings design
The settings window SHALL use the Claude Code design system with dark window background, styled section headers, and consistent typography.

#### Scenario: Visual consistency
- **WHEN** the settings window renders
- **THEN** it uses the app's dark theme, monospace headers, and consistent component styling matching the menu bar dropdown
