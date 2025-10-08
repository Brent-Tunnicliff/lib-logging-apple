// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation

protocol NotificationProvider: Sendable {
    var didBecomeActiveNotification: Notification.Name { get async }

    func notifications(named name: Notification.Name) async -> any AsyncSequence<Void, Never>
}

// MARK: - DefaultNotificationProvider

final class DefaultNotificationProvider: NotificationProvider {
    var didBecomeActiveNotification: Notification.Name {
        get async {
            await .didBecomeActiveNotification
        }
    }

    private let dateProvider: any DateProvider
    private let notificationCenter: NotificationCenter

    init(
        dateProvider: any DateProvider,
        notificationCenter: NotificationCenter
    ) {
        self.dateProvider = dateProvider
        self.notificationCenter = notificationCenter
    }

    convenience init() {
        self.init(
            dateProvider: DefaultDateProvider.shared,
            notificationCenter: .default
        )
    }

    func notifications(named name: Notification.Name) async -> any AsyncSequence<Void, Never> {
        await AsyncStream.async { [notificationCenter] continuation in
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
