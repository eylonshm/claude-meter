import SwiftUI

@main
struct ClaudeUsageApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var service = UsageDataService.shared
    @StateObject private var settings = AppSettings.shared

    var body: some Scene {
        // Menu Bar
        MenuBarExtra(menuBarTitle, systemImage: "sparkles") {
            MenuBarDropdown()
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

    private var menuBarTitle: String {
        if service.quotaError != nil && service.quota == .empty {
            return "—"
        }
        return "\(service.quota.weeklyAllPercent)%"
    }
}

// Hide dock icon — this is a menu-bar-only app
final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        // Trigger initial data fetch
        Task { @MainActor in
            await UsageDataService.shared.refresh()
        }
    }
}
