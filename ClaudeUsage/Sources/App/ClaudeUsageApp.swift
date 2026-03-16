import SwiftUI

@main
struct ClaudeUsageApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @ObservedObject private var service = UsageDataService.shared
    @ObservedObject private var settings = AppSettings.shared

    var body: some Scene {
        // Menu Bar
        MenuBarExtra {
            MenuBarDropdown()
        } label: {
            menuBarLabel
        }
        .menuBarExtraStyle(.window)

        // Settings Window
        Window("Claude Usage", id: "settings") {
            SettingsWindow()
                .frame(minWidth: 480, minHeight: 560)
        }
        .defaultSize(width: 520, height: 640)
        .windowStyle(.automatic)
    }

    @ViewBuilder
    private var menuBarLabel: some View {
        let percent = service.quota.weeklyAllPercent
        let isWarning = Double(percent) >= settings.warningThreshold
        let color: Color = isWarning ? settings.colors.accent : settings.colors.primary

        HStack(spacing: 4) {
            Image(systemName: "sparkle")
                .font(.system(size: 11))
            Text(service.quotaError != nil ? "—" : "\(percent)%")
                .font(.system(size: 11, weight: .medium, design: .monospaced))
        }
        .foregroundColor(color)
    }
}

// Hide dock icon — this is a menu-bar-only app
final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
    }
}
