// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation
import SwiftData

@testable import Logging

actor MockLoggingService: LoggingService {
    nonisolated let modelContainer: ModelContainer
    nonisolated let modelExecutor: any ModelExecutor

    @MainActor
    init() {
        self.modelContainer = LogEntity.mockContainer()
        self.modelExecutor = DefaultSerialModelExecutor(
            modelContext: ModelContext(modelContainer)
        )
    }

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
