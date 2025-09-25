// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation
import Synchronization

@testable import LoggingCore

final class MockNotificationProvider: NotificationProvider {
    // MARK: - notifications(named:)

    let didBecomeActiveNotification: Notification.Name = .mock(name: "didBecomeActiveNotification")

    typealias NotificationsResponse = @Sendable (Notification.Name) -> MockAsyncStream<Void>
    private let notificationsResponseMutex = Mutex<NotificationsResponse>({ _ in MockAsyncStream() })
    var notificationsResponse: NotificationsResponse {
        get { notificationsResponseMutex.withLock { $0 } }
        set { notificationsResponseMutex.withLock { $0 = newValue } }
    }
    func notifications(named name: Notification.Name) -> any AsyncSequence<Void, Never> {
        notificationsResponse(name)
    }
}
