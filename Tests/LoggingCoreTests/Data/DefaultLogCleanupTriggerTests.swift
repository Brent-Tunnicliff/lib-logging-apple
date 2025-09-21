// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation
import Testing

@testable import LoggingCore

@MainActor
struct LoggingCoreTests {
    private let logCleanupTrigger: DefaultLogCleanupTrigger
    private let mockNotificationProvider = MockNotificationProvider()
    private let userDefaults = UserDefaults.forTest()

    init() {
        logCleanupTrigger = DefaultLogCleanupTrigger(
            notificationProvider: mockNotificationProvider,
            userDefaults: userDefaults
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
    func registerForCleanupWithNoLastLogin(_ argument: RegisterForCleanupArgument) async {
        userDefaults.lastLogCleanup = argument.lastLogCleanup
        var triggerContinuation: AsyncStream<Void>.Continuation?
        let trigger = AsyncStream<Void> { continuation in
            triggerContinuation = continuation
        }
        mockNotificationProvider.notificationsResponse = { _ in trigger }

        let count = await withCheckedContinuation { checkedContinuation in
            Task {
                var count = 0
                for await _ in logCleanupTrigger.registerForCleanup() {
                    count += 1
                }
                checkedContinuation.resume(returning: count)
            }

            triggerContinuation?.yield()
            triggerContinuation?.finish()
        }

        #expect(count == argument.expectedCount)
    }
}
