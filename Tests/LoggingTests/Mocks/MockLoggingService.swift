// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation
import LoggingCore
import SwiftData
import Synchronization

final class MockLoggingService: LoggingService {
    package init() {}

    // MARK: - deleteLogs

    package struct DeleteLogsInput: Sendable {
        package let olderThanTimestamp: Date
    }
    package typealias DeleteLogsResponse = @Sendable (DeleteLogsInput) throws -> Void
    private let deleteLogsResponseMutex = Mutex<DeleteLogsResponse>({ _ in })
    package var deleteLogsResponse: DeleteLogsResponse {
        get { deleteLogsResponseMutex.withLock { $0 } }
        set { deleteLogsResponseMutex.withLock { $0 = newValue } }
    }
    package func deleteLogs(olderThan timestamp: Date) async throws {
        try deleteLogsResponse(
            DeleteLogsInput(
                olderThanTimestamp: timestamp
            )
        )
    }

    // MARK: - exportLogs

    func exportLogs() async throws -> (progress: AsyncStream<Double>, url: Task<URL, any Error>) {
        let (stream, continuation) = AsyncStream<Double>.makeStream()
        continuation.yield(0.3)
        continuation.yield(0.6)
        continuation.yield(1)
        continuation.finish()
        return (stream, Task { .mock })
    }

    // MARK: - save

    func save() async throws {}

    // MARK: - storeLog

    package struct StoreLogInput: Sendable {
        package let error: (any Error)?
        package let logLevel: LogLevel
        package let message: String
        package let packageName: String
        package let tag: LogTag
        package let timestamp: Date
        package let thread: String
    }
    package typealias StoreLogResponse = @Sendable (StoreLogInput) -> Void
    private let storeLogResponseMutex = Mutex<StoreLogResponse>({ _ in })
    package var storeLogResponse: StoreLogResponse {
        get { storeLogResponseMutex.withLock { $0 } }
        set { storeLogResponseMutex.withLock { $0 = newValue } }
    }
    package func storeLog(
        error: (any Error)?,
        logLevel: LogLevel,
        message: String,
        packageName: String,
        tag: LogTag,
        timestamp: Date,
        thread: String
    ) async {
        storeLogResponse(
            StoreLogInput(
                error: error,
                logLevel: logLevel,
                message: message,
                packageName: packageName,
                tag: tag,
                timestamp: timestamp,
                thread: thread
            )
        )
    }
}
