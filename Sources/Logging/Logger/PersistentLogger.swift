// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation

final class PersistentLogger {
    private let loggingService: any LoggingService
    private let packageName: String
    private let systemLogger: SystemLogger

    init(
        loggingService: any LoggingService = DefaultLoggingService(),
        packageName: String
    ) {
        self.loggingService = loggingService
        self.packageName = packageName
        self.systemLogger = SystemLogger(packageName: packageName)
    }
}

// MARK: - Logger

extension PersistentLogger: Logger {
    func log(level: LogLevel, _ message: String, tag: LogTag, error: (any Error)?) {
        let timestamp = Date()
        systemLogger.log(level: level, message, tag: tag, error: error)

        Task {
            do {
                try await loggingService.storeLog(
                    error: error,
                    loglevel: level,
                    message: message,
                    packageName: packageName,
                    tag: tag,
                    timestamp: timestamp
                )
            } catch {
                let catchMessage = "Storing log failed: \(error)"
                assertionFailure(catchMessage)
                systemLogger.critical(catchMessage, error: error)
            }
        }
    }
}
