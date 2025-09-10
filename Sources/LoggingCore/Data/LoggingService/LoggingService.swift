// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

package import Foundation

package protocol LoggingService: Sendable {
    func deleteLogs(olderThan timestamp: Date) async throws

    func exportLogs() async throws -> URL

    func storeLog(
        error: (any Error)?,
        logLevel: LogLevel,
        message: String,
        packageName: String,
        tag: LogTag,
        timestamp: Date
    ) async
}
