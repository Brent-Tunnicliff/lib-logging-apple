// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation
import Synchronization
import Testing

@testable import LoggingCore

struct NotificationProviderTests {
    private let notificationCenter = WrappedNotificationCenter()
    private let notificationName = Notification.Name(rawValue: "DefaultNotificationProviderTestsMock")
    private let notificationProvider: DefaultNotificationProvider

    init() {
        self.notificationProvider = DefaultNotificationProvider(
            dateProvider: MockDateProvider(),
            notificationCenter: notificationCenter
        )
    }

    @Test(.timeLimit(.minutes(1)))
    func notificationsNamed() async throws {
        let setupIsReady = Atomic(false)
        let notificationTriggered = Task {
            let stream = notificationProvider.notifications(named: notificationName)
            setupIsReady.store(true, ordering: .sequentiallyConsistent)
            for await _ in stream {
                return true
            }

            return false
        }

        while !setupIsReady.load(ordering: .sequentiallyConsistent)
            || !notificationCenter.addObserverCalled.load(ordering: .sequentiallyConsistent)
        {
            try await Task.sleep(for: .milliseconds(10))
        }

        notificationCenter.post(name: notificationName, object: nil)
        await #expect(notificationTriggered.value == true)
    }
}

private final class WrappedNotificationCenter: NotificationCenter, @unchecked Sendable {
    let addObserverCalled = Atomic(false)

    override func addObserver(
        _ observer: Any,
        selector aSelector: Selector,
        name aName: NSNotification.Name?,
        object anObject: Any?
    ) {
        super.addObserver(observer, selector: aSelector, name: aName, object: anObject)
        addObserverCalled.store(true, ordering: .sequentiallyConsistent)
    }

    override func addObserver(
        forName name: NSNotification.Name?,
        object obj: Any?,
        queue: OperationQueue?,
        using block: @escaping @Sendable (Notification) -> Void
    ) -> any NSObjectProtocol {
        let result = super.addObserver(forName: name, object: obj, queue: queue, using: block)
        addObserverCalled.store(true, ordering: .sequentiallyConsistent)
        return result
    }
}
