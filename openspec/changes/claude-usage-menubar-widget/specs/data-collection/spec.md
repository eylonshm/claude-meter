## ADDED Requirements

### Requirement: Read local stats cache
The system SHALL read `~/.claude/stats-cache.json` and parse daily activity (messages, sessions, tool calls), daily model tokens, cumulative model usage, total sessions/messages, and hour counts.

#### Scenario: Stats file exists and is valid
- **WHEN** the stats fetcher runs
- **THEN** it reads and parses all fields from stats-cache.json into a StatsData model

#### Scenario: Stats file does not exist
- **WHEN** `~/.claude/stats-cache.json` is missing
- **THEN** the system shows a "Claude CLI not detected" state with setup instructions

#### Scenario: Stats file is malformed
- **WHEN** the JSON is invalid or has unexpected schema
- **THEN** the system logs the error and shows "Unable to parse stats" with last known good data if available

### Requirement: Extract live quota via CLI
The system SHALL spawn a pseudo-TTY process running `claude`, send the `/usage` command, capture and parse the ANSI output to extract session usage percentage, weekly usage percentage (all models), weekly usage percentage (Sonnet only), and their respective reset times.

#### Scenario: Claude CLI is installed and authenticated
- **WHEN** the quota fetcher runs
- **THEN** it spawns a claude session, sends /usage, parses the output, and returns QuotaData with session_percent, weekly_all_percent, weekly_sonnet_percent, session_reset_time, weekly_all_reset_time, weekly_sonnet_reset_time

#### Scenario: Claude CLI is not installed
- **WHEN** the `claude` binary is not found in PATH
- **THEN** the system shows "Claude CLI not found" with installation link

#### Scenario: Claude CLI is not authenticated
- **WHEN** the claude session fails to start or returns an auth error
- **THEN** the system shows "Not logged in — run `claude` to authenticate"

#### Scenario: Parse failure
- **WHEN** the /usage output doesn't match expected patterns
- **THEN** the system logs the raw output for debugging, shows "Quota data unavailable" and falls back to stats-only mode

### Requirement: Periodic background refresh
The system SHALL refresh data on a configurable interval (default: 10 minutes). Stats file reads and quota fetches SHALL run concurrently. After each refresh, the system SHALL update the shared App Group container so widgets can access fresh data.

#### Scenario: Timer-based refresh
- **WHEN** the refresh interval elapses
- **THEN** both stats and quota fetchers run concurrently, results are published to all observers, and widget timelines are reloaded

#### Scenario: Manual refresh
- **WHEN** the user triggers a manual refresh (from settings UI or menu bar)
- **THEN** the system immediately runs both fetchers regardless of timer state and resets the timer

### Requirement: Compute derived metrics
The system SHALL compute today's stats, this week's stats, this month's stats, and per-model percentage breakdowns from the raw stats-cache data by aggregating dailyActivity and dailyModelTokens arrays.

#### Scenario: Aggregate today
- **WHEN** stats data is available
- **THEN** the system filters dailyActivity for today's date and returns messages, sessions, tool calls, and token counts

#### Scenario: Aggregate this week
- **WHEN** stats data is available
- **THEN** the system sums dailyActivity from Monday through today and returns totals
