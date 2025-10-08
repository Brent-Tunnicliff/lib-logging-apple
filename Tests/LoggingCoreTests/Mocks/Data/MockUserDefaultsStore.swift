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

    enum MockUserDefaultsStoreError: Error {
        case waitForLastLogCleanupTimedOut
    }
}
