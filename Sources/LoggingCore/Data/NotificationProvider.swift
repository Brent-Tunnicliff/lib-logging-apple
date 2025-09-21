// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation

protocol NotificationProvider: Sendable {
    associatedtype NotificationsAsyncSequence: AsyncSequence<Void, Never> & Sendable

    var didBecomeActiveNotification: Notification.Name { get async }

    func notifications(named name: Notification.Name) -> NotificationsAsyncSequence
}

// MARK: - DefaultNotificationProvider

final class DefaultNotificationProvider: NotificationProvider {
    var didBecomeActiveNotification: Notification.Name {
        get async {
            await .didBecomeActiveNotification
        }
    }

    private let notificationCenter: NotificationCenter

    init(notificationCenter: NotificationCenter) {
        self.notificationCenter = notificationCenter
    }

    convenience init() {
        self.init(notificationCenter: .default)
    }

    func notifications(named name: Notification.Name) -> AsyncStream<Void> {
        .async { [notificationCenter] continuation in
            for await _ in notificationCenter.notifications(named: name) {
                try Task.checkCancellation()
                continuation.yield()
            }
        }
    }
}

extension NSNotification.Name {
    @MainActor
    fileprivate static var didBecomeActiveNotification: NSNotification.Name {
        #if canImport(WatchKit)
            didBecomeActiveNotificationWatchKit
        #elseif canImport(UIKit)
            didBecomeActiveNotificationUIKit
        #elseif canImport(IOKit)
            didBecomeActiveNotificationIOKit
        #endif
    }
}

#if canImport(WatchKit)
    import WatchKit

    extension NSNotification.Name {
        @MainActor
        private static var didBecomeActiveNotificationWatchKit: NSNotification.Name {
            WKApplication.didBecomeActiveNotification
        }
    }
#elseif canImport(UIKit)
    import UIKit

    extension NSNotification.Name {
        private static var didBecomeActiveNotificationUIKit: NSNotification.Name {
            UIApplication.didBecomeActiveNotification
        }
    }
#elseif canImport(AppKit)
    import AppKit

    extension NSNotification.Name {
        private static var didBecomeActiveNotificationIOKit: NSNotification.Name {
            NSApplication.didBecomeActiveNotification
        }
    }
#endif
