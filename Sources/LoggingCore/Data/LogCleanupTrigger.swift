// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation

protocol LogCleanupTrigger: Sendable {
    /// Will yield a value if cleanup should be performed.
    func registerForCleanup() async -> any AsyncSequence<Void, Never>

    /// Store log cleanup performed.
    ///
    /// This is very important to call as it affects how often `registerForCleanup()` returns.
    func storeLogCleanup(timestamp: Date) async
}

// MARK: - DefaultLogCleanupTrigger

actor DefaultLogCleanupTrigger {
    private let cleanupIntervals = Duration.days(1).asTimeInterval
    private let dateProvider: any DateProvider
    private let notificationProvider: any NotificationProvider
    private let userDefaults: any UserDefaultsStore

    private var shouldPerformCleanup: Bool {
        guard let lastLogCleanup = userDefaults.lastLogCleanup else {
            return true
        }

        return lastLogCleanup.addingTimeInterval(cleanupIntervals) <= dateProvider.now
    }

    init(
        dateProvider: any DateProvider,
        notificationProvider: any NotificationProvider,
        userDefaults: any UserDefaultsStore
    ) {
        self.dateProvider = dateProvider
        self.notificationProvider = notificationProvider
        self.userDefaults = userDefaults
    }

    init() {
        self.init(
            dateProvider: DefaultDateProvider.shared,
            notificationProvider: DefaultNotificationProvider(),
            userDefaults: UserDefaults.standard
        )
    }

    private func write(lastLogCleanup: Date) {
        userDefaults.lastLogCleanup = lastLogCleanup
    }
}

extension DefaultLogCleanupTrigger: LogCleanupTrigger {
    nonisolated func registerForCleanup() async -> any AsyncSequence<Void, Never> {
        await AsyncStream.async(
            bufferingPolicy: .bufferingNewest(1)
        ) { [weak self, notificationProvider] continuation in
            // Trigger one immediately.
            continuation.yield()

            // Start listening for notifications
            let notificationName = await notificationProvider.didBecomeActiveNotification
            let notificationsStream = await notificationProvider.notifications(named: notificationName)
            for await _ in notificationsStream {
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

    func storeLogCleanup(timestamp: Date) {
        write(lastLogCleanup: timestamp)
    }
}
