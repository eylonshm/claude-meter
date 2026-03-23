import Foundation
import Sparkle
import Combine

final class UpdaterViewModel: ObservableObject {
    private let updater: SPUUpdater
    private var cancellables = Set<AnyCancellable>()

    @Published var automaticallyChecksForUpdates: Bool {
        didSet { updater.automaticallyChecksForUpdates = automaticallyChecksForUpdates }
    }
    @Published var automaticallyDownloadsUpdates: Bool {
        didSet { updater.automaticallyDownloadsUpdates = automaticallyDownloadsUpdates }
    }
    @Published var updateCheckInterval: TimeInterval {
        didSet { updater.updateCheckInterval = updateCheckInterval }
    }
    @Published var canCheckForUpdates: Bool = false

    var lastUpdateCheckDate: Date? { updater.lastUpdateCheckDate }

    init(updater: SPUUpdater) {
        self.updater = updater
        self.automaticallyChecksForUpdates = updater.automaticallyChecksForUpdates
        self.automaticallyDownloadsUpdates = updater.automaticallyDownloadsUpdates
        // Default to weekly (604800) if interval is 0 or not set
        let interval = updater.updateCheckInterval
        self.updateCheckInterval = interval > 0 ? interval : 604800
        self.canCheckForUpdates = updater.canCheckForUpdates

        updater.publisher(for: \.canCheckForUpdates)
            .receive(on: DispatchQueue.main)
            .assign(to: &$canCheckForUpdates)
    }

    func checkForUpdates() {
        updater.checkForUpdates()
    }
}
