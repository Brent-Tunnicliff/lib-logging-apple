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

    private let viewCriticalLogsValue = Atomic(true)
    var viewCriticalLogs: Bool {
        get { viewCriticalLogsValue.load(ordering: .sequentiallyConsistent) }
        set { viewCriticalLogsValue.store(newValue, ordering: .sequentiallyConsistent) }
    }

    private let viewDebugLogsValue = Atomic(true)
    var viewDebugLogs: Bool {
        get { viewDebugLogsValue.load(ordering: .sequentiallyConsistent) }
        set { viewDebugLogsValue.store(newValue, ordering: .sequentiallyConsistent) }
    }

    private let viewErrorLogsValue = Atomic(true)
    var viewErrorLogs: Bool {
        get { viewErrorLogsValue.load(ordering: .sequentiallyConsistent) }
        set { viewErrorLogsValue.store(newValue, ordering: .sequentiallyConsistent) }
    }

    private let viewInfoLogsValue = Atomic(true)
    var viewInfoLogs: Bool {
        get { viewInfoLogsValue.load(ordering: .sequentiallyConsistent) }
        set { viewInfoLogsValue.store(newValue, ordering: .sequentiallyConsistent) }
    }

    enum MockUserDefaultsStoreError: Error {
        case waitForLastLogCleanupTimedOut
    }
}
