## ADDED Requirements

### Requirement: Color palette
The system SHALL define a default color palette inspired by Claude Code CLI: background (#1A1A2E), surface (#16213E), primary/indigo (#B1B9F9), accent/coral (#D77757), text (#E0E0E0), muted (#888888), success (#4CAF50), warning (#FF9800). All colors SHALL be user-configurable in the Settings UI with color pickers, with a "Reset to defaults" button.

#### Scenario: Color usage
- **WHEN** any UI surface renders
- **THEN** it uses colors from the user's configured palette (or defaults), with background for window/widget backgrounds, surface for cards, primary for progress fills and highlights, accent for warnings and branding, text for primary content, muted for secondary labels

#### Scenario: Custom colors
- **WHEN** the user changes a color in settings
- **THEN** all UI surfaces (menu bar dropdown, settings window, widgets) update to reflect the new color

### Requirement: Typography
The system SHALL use SF Mono as the primary font family across all UI surfaces. Sizes: title (16pt bold), heading (13pt semibold), body (12pt regular), caption (10pt regular), stat-value (20pt bold).

#### Scenario: Font rendering
- **WHEN** text renders in any UI surface
- **THEN** it uses SF Mono at the specified sizes, falling back to Menlo if SF Mono is unavailable

### Requirement: Progress bar component
The system SHALL provide a reusable progress bar component with rounded ends, configurable fill color (default: primary/indigo), track color (surface), and optional percentage label.

#### Scenario: Normal progress
- **WHEN** a progress bar renders with value 0-79%
- **THEN** it shows an indigo fill on dark track with rounded corners

#### Scenario: High usage progress
- **WHEN** a progress bar renders with value at or above the warning threshold (default 80%, configurable in settings)
- **THEN** it shows a coral/warning fill to indicate warning state

### Requirement: Configurable warning threshold
The system SHALL allow the user to configure the warning threshold percentage (default: 80%) in Settings. When any quota metric exceeds this threshold, progress bars switch to warning color and the menu bar indicator turns warning color.

#### Scenario: Custom threshold
- **WHEN** the user sets the warning threshold to 60%
- **THEN** progress bars and menu bar indicator switch to warning color at 60% instead of 80%

### Requirement: Section divider component
The system SHALL provide a section divider styled as a horizontal rule using `────` characters in muted color, matching the Claude Code CLI aesthetic.

#### Scenario: Divider rendering
- **WHEN** a section divider renders
- **THEN** it displays a full-width line using repeated `─` characters in muted (#888888) color

### Requirement: Stat row component
The system SHALL provide a reusable stat row component with left-aligned label (muted text) and right-aligned value (primary text), with consistent horizontal padding.

#### Scenario: Stat display
- **WHEN** a stat row renders with label "Messages" and value "1,234"
- **THEN** it displays the label left-aligned in muted color and the value right-aligned in primary text color, both in SF Mono
