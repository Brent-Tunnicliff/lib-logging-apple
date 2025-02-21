// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation

@testable import Logging

actor MockLoggingService: LoggingService {
    var deleteLogsCalled: Bool { !deleteLogsInput.isEmpty }
    private(set) var deleteLogsInput: [Date] = []
    private var deleteLogsThrow: (any Error)? = nil
    func deleteLogs(olderThan timestamp: Date) async throws {
        deleteLogsInput.append(timestamp)

        if let deleteLogsThrow {
            throw deleteLogsThrow
        }
    }

    private var storeLogCompletionHandler: () -> Void = {}
    private var storeLogThrow: (any Error)? = nil
    var storeLogCalled: Bool { !storeLogInput.isEmpty }
    typealias StoreLogInputType = (
        error: (any Error)?,
        logLevel: LogLevel,
        message: String,
        packageName: String,
        tag: LogTag,
        timestamp: Date
    )
    private(set) var storeLogInput: [StoreLogInputType] = []
    func storeLog(
        error: (any Error)?,
        logLevel: LogLevel,
        message: String,
        packageName: String,
        tag: LogTag,
        timestamp: Date
    ) async throws {
        defer {
            storeLogCompletionHandler()
        }

        storeLogInput.append((error, logLevel, message, packageName, tag, timestamp))

        if let storeLogThrow {
            throw storeLogThrow
        }
    }

    // MARK: - State Injection

    func inject(deleteLogsThrow: (any Error)?) {
        self.deleteLogsThrow = deleteLogsThrow
    }

    func inject(storeLogCompletionHandler: @escaping () -> Void) {
        self.storeLogCompletionHandler = storeLogCompletionHandler
    }

    func inject(storeLogThrow: (any Error)?) {
        self.storeLogThrow = storeLogThrow
    }
}
