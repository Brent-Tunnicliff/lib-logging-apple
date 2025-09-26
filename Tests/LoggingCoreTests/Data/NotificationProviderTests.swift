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
        var setupIsReady = false
        let notificationTriggered = Task {
            let stream = notificationProvider.notifications(named: notificationName)
            setupIsReady = true
            for await _ in stream {
                return true
            }

            return false
        }

        while setupIsReady == false {
            try await Task.sleep(for: .milliseconds(10))
        }

        notificationCenter.post(name: notificationName, object: nil)
        await #expect(notificationTriggered.value == true)
    }
}
