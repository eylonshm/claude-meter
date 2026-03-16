import SwiftUI
import ServiceManagement

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
    }

    private var menuBarTitle: String {
        if service.quotaError != nil && service.quota == .empty {
            return "—"
        }
        return "\(service.quota.weeklyAllPercent)%"
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        let settings = AppSettings.shared
        let isFirstLaunch = !UserDefaults.standard.bool(forKey: "hasLaunchedBefore")

        if isFirstLaunch {
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")

            // Enable launch at login on first run
            settings.launchAtLogin = true
            LoginItemManager.setEnabled(true)
        }

        // Start polling immediately
        Task { @MainActor in
            await UsageDataService.shared.refresh()
        }
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            SettingsWindowController.shared.open()
        }
        return true
    }
}
