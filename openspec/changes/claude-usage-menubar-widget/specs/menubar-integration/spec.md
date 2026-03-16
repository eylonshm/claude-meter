## ADDED Requirements

### Requirement: Menu bar status item
The system SHALL display a menu bar icon showing a compact usage indicator. The icon SHALL be the Claude logo (stylized) or a gauge icon. Next to the icon, the system SHALL display the weekly quota percentage as compact text (e.g., "4%").

#### Scenario: Normal usage
- **WHEN** weekly quota is below 80%
- **THEN** the menu bar shows the icon with percentage in default color

#### Scenario: High usage warning
- **WHEN** weekly quota exceeds 80%
- **THEN** the menu bar percentage text turns coral (#D77757) as a visual warning

#### Scenario: No data
- **WHEN** quota data is unavailable
- **THEN** the menu bar shows the icon with "—" instead of a percentage

### Requirement: Menu bar dropdown panel
The system SHALL display a popover panel when the menu bar icon is clicked, containing sections for live quota, today's stats, model breakdown, and quick actions.

#### Scenario: Dropdown layout
- **WHEN** the user clicks the menu bar icon
- **THEN** a styled popover appears with: (1) Quota section with three progress bars and reset times, (2) Today section with messages/sessions/tool calls/tokens, (3) Models section with token distribution, (4) Footer with last updated time, refresh button, and settings gear icon

#### Scenario: Refresh action
- **WHEN** the user clicks the refresh button in the dropdown
- **THEN** the system triggers an immediate data refresh and shows a loading spinner until complete

#### Scenario: Open settings
- **WHEN** the user clicks the settings gear icon
- **THEN** the settings window opens and the dropdown closes

### Requirement: Dropdown design
The dropdown panel SHALL use the Claude Code design system with dark background, section dividers styled as `────` lines, SF Mono typography, and compact row layout matching CLI output aesthetics.

#### Scenario: Visual style
- **WHEN** the dropdown renders
- **THEN** it uses dark background (#1A1A2E), indigo progress bars, coral accents, monospace font, and CLI-style section dividers
