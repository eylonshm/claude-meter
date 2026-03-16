import Foundation

final class QuotaFetcher {
    private let settings = AppSettings.shared

    func fetch() async throws -> QuotaData {
        let claudePath = resolveClaudePath()
        guard FileManager.default.fileExists(atPath: claudePath) else {
            throw FetchError.cliNotFound
        }

        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .utility).async {
                do {
                    let output = try self.runClaudeUsage(claudePath: claudePath)
                    let quota = try self.parseUsageOutput(output)
                    continuation.resume(returning: quota)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    // MARK: - PTY Process

    private func runClaudeUsage(claudePath: String) throws -> String {
        var primary: Int32 = 0
        var secondary: Int32 = 0

        guard openpty(&primary, &secondary, nil, nil, nil) == 0 else {
            throw FetchError.parseFailed("Failed to open PTY")
        }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: claudePath)
        process.arguments = []
        process.environment = ProcessInfo.processInfo.environment

        let primaryHandle = FileHandle(fileDescriptor: primary, closeOnDealloc: false)

        process.standardInput = FileHandle(fileDescriptor: secondary, closeOnDealloc: false)
        process.standardOutput = FileHandle(fileDescriptor: secondary, closeOnDealloc: false)
        process.standardError = FileHandle(fileDescriptor: secondary, closeOnDealloc: false)

        try process.run()

        // Wait for prompt to appear
        Thread.sleep(forTimeInterval: 3.0)

        // Send /usage command
        let usageCmd = "/usage\r".data(using: .utf8)!
        primaryHandle.write(usageCmd)

        // Wait for output
        Thread.sleep(forTimeInterval: 5.0)

        // Read output
        let outputData = primaryHandle.availableData
        let rawOutput = String(data: outputData, encoding: .utf8) ?? ""

        // Send escape to close the usage panel
        primaryHandle.write(Data([0x1B]))
        Thread.sleep(forTimeInterval: 0.5)

        // Send /exit
        let exitCmd = "/exit\r".data(using: .utf8)!
        primaryHandle.write(exitCmd)

        // Give it a moment to exit
        Thread.sleep(forTimeInterval: 1.0)

        if process.isRunning {
            process.terminate()
        }

        close(primary)
        close(secondary)

        return rawOutput
    }

    // MARK: - Output Parsing

    private func parseUsageOutput(_ raw: String) throws -> QuotaData {
        // Strip ANSI escape sequences
        let stripped = raw
            .replacingOccurrences(of: "\\x1b\\[[0-9;]*[a-zA-Z]", with: "", options: .regularExpression)
            .replacingOccurrences(of: "\\x1b\\[\\?[0-9]*[a-z]", with: "", options: .regularExpression)
            .replacingOccurrences(of: "\\x1b\\[[0-9;]*m", with: "", options: .regularExpression)
            .replacingOccurrences(of: "\u{1B}\\[[0-9;]*[a-zA-Z]", with: "", options: .regularExpression)
            .replacingOccurrences(of: "\u{1B}\\[\\?[0-9]*[a-z]", with: "", options: .regularExpression)

        var sessionPercent = 0
        var sessionReset = "—"
        var weeklyAllPercent = 0
        var weeklyAllReset = "—"
        var weeklySonnetPercent = 0
        var weeklySonnetReset = "—"

        let lines = stripped.components(separatedBy: .newlines)
        var currentSection = ""

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            if trimmed.contains("Current session") {
                currentSection = "session"
            } else if trimmed.contains("all models") {
                currentSection = "weekly_all"
            } else if trimmed.contains("Sonnet only") {
                currentSection = "weekly_sonnet"
            }

            // Extract percentage
            if let percentMatch = trimmed.range(of: "(\\d+)%\\s*used", options: .regularExpression) {
                let percentStr = trimmed[percentMatch]
                    .replacingOccurrences(of: "%", with: "")
                    .replacingOccurrences(of: "used", with: "")
                    .trimmingCharacters(in: .whitespaces)
                let percent = Int(percentStr) ?? 0

                switch currentSection {
                case "session": sessionPercent = percent
                case "weekly_all": weeklyAllPercent = percent
                case "weekly_sonnet": weeklySonnetPercent = percent
                default: break
                }
            }

            // Extract reset time
            if trimmed.contains("Reset") || trimmed.contains("Rese") {
                let resetText = trimmed
                    .replacingOccurrences(of: "Resets", with: "")
                    .replacingOccurrences(of: "Rese s", with: "")
                    .replacingOccurrences(of: "Reset", with: "")
                    .trimmingCharacters(in: .whitespaces)

                if !resetText.isEmpty {
                    switch currentSection {
                    case "session": sessionReset = resetText
                    case "weekly_all": weeklyAllReset = resetText
                    case "weekly_sonnet": weeklySonnetReset = resetText
                    default: break
                    }
                }
            }
        }

        // Validate we got at least some data
        if sessionPercent == 0 && weeklyAllPercent == 0 && weeklySonnetPercent == 0 {
            // Might still be valid if usage is actually 0%, but try alternate parsing
            if !stripped.contains("used") {
                throw FetchError.parseFailed("No usage data found in output")
            }
        }

        return QuotaData(
            sessionPercent: sessionPercent,
            sessionResetTime: sessionReset,
            weeklyAllPercent: weeklyAllPercent,
            weeklyAllResetTime: weeklyAllReset,
            weeklySonnetPercent: weeklySonnetPercent,
            weeklySonnetResetTime: weeklySonnetReset
        )
    }

    // MARK: - CLI Path Resolution

    private func resolveClaudePath() -> String {
        if !settings.cliPath.isEmpty {
            return settings.cliPath
        }

        // Check common locations
        let candidates = [
            "/usr/local/bin/claude",
            "/opt/homebrew/bin/claude",
            "\(FileManager.default.homeDirectoryForCurrentUser.path)/.claude/local/claude",
            "\(FileManager.default.homeDirectoryForCurrentUser.path)/.local/bin/claude"
        ]

        for path in candidates {
            if FileManager.default.fileExists(atPath: path) {
                return path
            }
        }

        // Try which
        let process = Process()
        let pipe = Pipe()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/which")
        process.arguments = ["claude"]
        process.standardOutput = pipe
        process.standardError = FileHandle.nullDevice
        try? process.run()
        process.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let result = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return result.isEmpty ? "/usr/local/bin/claude" : result
    }
}
