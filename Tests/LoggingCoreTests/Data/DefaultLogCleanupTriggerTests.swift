// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation
import Synchronization
import Testing

@testable import LoggingCore

struct LoggingCoreTests {
    private let logCleanupTrigger: DefaultLogCleanupTrigger
    private let mockNotificationProvider = MockNotificationProvider()
    private let mockUserDefaultsStore = MockUserDefaultsStore()

    init() {
        logCleanupTrigger = DefaultLogCleanupTrigger(
            notificationProvider: mockNotificationProvider,
            userDefaults: mockUserDefaultsStore
        )
    }

    @Test(.timeLimit(.minutes(1)))
    func registerForCleanupYieldsImmediately() async {
        // Make sure the mock hangs.
        mockNotificationProvider.notificationsResponse = { _ in .mock(yieldValue: false, shouldComplete: false) }

        await withCheckedContinuation { continuation in
            Task {
                for await _ in logCleanupTrigger.registerForCleanup() {
                    continuation.resume()
                }
            }
        }

        // No need to expect anything.
        // As long as `withCheckedContinuation` returns and the test doesn't timeout then it is a pass.
    }

    enum RegisterForCleanupArgument: CaseIterable {
        case noLastLogin
        case lastLoginDueForNewCleanup
        case lastLoginForIgnore
        case lastLoginRecent

        private static let oneDayInSeconds: TimeInterval = 86_400
        var lastLogCleanup: Date? {
            switch self {
            case .noLastLogin:
                nil
            case .lastLoginDueForNewCleanup:
                // Over one day ago
                Date().addingTimeInterval(-(Self.oneDayInSeconds + 120))
            case .lastLoginForIgnore:
                // Less than one day ago
                Date().addingTimeInterval(-(Self.oneDayInSeconds - 120))
            case .lastLoginRecent:
                Date()
            }
        }

        // The trigger always happens when first subscribing to it.
        // So every case should trigger at least once.
        var expectedCount: Int {
            switch self {
            case .noLastLogin: 2
            case .lastLoginDueForNewCleanup: 2
            case .lastLoginForIgnore: 1
            case .lastLoginRecent: 1
            }
        }
    }

    @Test(
        .timeLimit(.minutes(1)),
        arguments: RegisterForCleanupArgument.allCases
    )
    func registerForClean(_ argument: RegisterForCleanupArgument) async throws {
        mockUserDefaultsStore.lastLogCleanup = argument.lastLogCleanup
        var triggerContinuation: AsyncStream<Void>.Continuation?
        let trigger = AsyncStream<Void> { continuation in
            triggerContinuation = continuation
        }
        mockNotificationProvider.notificationsResponse = { _ in trigger }

        guard let triggerContinuation else {
            Issue.record("triggerContinuation is nil")
            return
        }

        let countReadyMutex = Mutex(false)
        let countTask = Task {
            var count = 0
            for await _ in logCleanupTrigger.registerForCleanup() {
                if count == 0 {
                    countReadyMutex.withLock { $0 = true }
                }

                count += 1
            }
            return count
        }

        while countReadyMutex.withLock({ $0 }) == false {
            try await Task.sleep(for: .milliseconds(10))
        }

        triggerContinuation.yield()
        triggerContinuation.finish()

        let count = await countTask.value

        #expect(count == argument.expectedCount)
    }
}
