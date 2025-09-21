// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation

actor DefaultLogCleanupTrigger {
    private let cleanupIntervals = TimeInterval(duration: .days(1))
    private let notificationProvider: any NotificationProvider
    private let userDefaults: UserDefaults

    private var shouldPerformCleanup: Bool {
        guard let lastLogCleanup = userDefaults.lastLogCleanup else {
            return true
        }

        return lastLogCleanup.addingTimeInterval(cleanupIntervals) <= Date()
    }

    init(
        notificationProvider: any NotificationProvider,
        userDefaults: UserDefaults
    ) {
        self.notificationProvider = notificationProvider
        self.userDefaults = userDefaults
    }

    init() {
        self.init(
            notificationProvider: DefaultNotificationProvider(),
            userDefaults: .standard
        )
    }

    private func write(lastLogCleanup: Date) {
        userDefaults.lastLogCleanup = lastLogCleanup
    }
}

extension DefaultLogCleanupTrigger: LogCleanupTrigger {
    nonisolated func registerForCleanup() -> AsyncStream<Void> {
        .async(bufferingPolicy: .bufferingNewest(1)) { [weak self, notificationProvider] continuation in
            // Trigger one immediately.
            continuation.yield()

            // Start listening for notifications
            let notificationName = await notificationProvider.didBecomeActiveNotification
            for await _ in notificationProvider.notifications(named: notificationName) {
                try Task.checkCancellation()
                // If self is nil then return
                guard let self else {
                    return
                }

                // If shouldn't perform cleanup then skip this loop and try again next time.
                guard await shouldPerformCleanup else {
                    continue
                }

                continuation.yield()
            }
        }
    }

    nonisolated func storeLogCleanup(timestamp: Date) {
        Task {
            await write(lastLogCleanup: timestamp)
        }
    }
}
