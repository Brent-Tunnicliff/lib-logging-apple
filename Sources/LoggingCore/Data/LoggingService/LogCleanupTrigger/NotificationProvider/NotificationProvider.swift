// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation

protocol NotificationProvider: Sendable {
    associatedtype NotificationsAsyncSequence: AsyncSequence<Void, Never> & Sendable

    var didBecomeActiveNotification: Notification.Name { get async }

    func notifications(named name: Notification.Name) -> NotificationsAsyncSequence
}
