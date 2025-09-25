// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation
import Synchronization

@testable import LoggingCore

final class MockUserDefaultsStore: UserDefaultsStore, Sendable {
    private let minimalLogLevelMutex = Mutex<LogLevel>(.info)
    var minimalLogLevel: LogLevel {
        get { minimalLogLevelMutex.withLock { $0 } }
        set { minimalLogLevelMutex.withLock { $0 = newValue } }
    }

    private let lastLogCleanupMutex = Mutex<Date?>(nil)
    var lastLogCleanup: Date? {
        get { lastLogCleanupMutex.withLock { $0 } }
        set { lastLogCleanupMutex.withLock { $0 = newValue } }
    }

    func waitForLastLogCleanup(timeout duration: Duration = .seconds(1)) async throws {
        let timeout = Date(timeIntervalSinceNow: Double(duration.components.seconds))
        while lastLogCleanup == nil {
            guard Date() < timeout else {
                throw MockUserDefaultsStoreError.waitForLastLogCleanupTimedOut
            }

            try await Task.sleep(for: .milliseconds(10))
        }
    }

    enum MockUserDefaultsStoreError: Error {
        case waitForLastLogCleanupTimedOut
    }
}
