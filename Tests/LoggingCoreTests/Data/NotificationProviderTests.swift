// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation
import Testing

@testable import LoggingCore

@MainActor
struct NotificationProviderTests {
    private let notificationCenter = NotificationCenter.default
    private let notificationName = Notification.Name(rawValue: "DefaultNotificationProviderTestsMock")
    private let notificationProvider: DefaultNotificationProvider

    init() {
        self.notificationProvider = DefaultNotificationProvider(
            notificationCenter: notificationCenter
        )
    }

    @Test(.timeLimit(.minutes(1)))
    func notificationsNamed() async throws {
        let notificationTriggered = Task {
            for await _ in notificationProvider.notifications(named: notificationName) {
                return true
            }

            return false
        }

        // We need to wait for the above to setup before we can continue.
        try await Task.sleep(for: .milliseconds(500))
        notificationCenter.post(name: notificationName, object: nil)
        await #expect(notificationTriggered.value == true)
    }
}
