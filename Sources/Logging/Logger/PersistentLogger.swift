// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation

final class PersistentLogger {
    private let loggingService: any LoggingService
    private let packageName: String
    private let systemLogger: any Logger

    convenience init(
        loggingService: any LoggingService = DefaultLoggingService(),
        packageName: String
    ) {
        self.init(
            loggingService: loggingService,
            packageName: packageName,
            systemLogger: SystemLogger(packageName: packageName)
        )
    }

    init(
        loggingService: any LoggingService,
        packageName: String,
        systemLogger: any Logger
    ) {
        self.loggingService = loggingService
        self.packageName = packageName
        self.systemLogger = systemLogger
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
                    logLevel: level,
                    message: message,
                    packageName: packageName,
                    tag: tag,
                    timestamp: timestamp
                )
            } catch {
                systemLogger.critical("Storing log failed: \(error)", error: error)
            }
        }
    }
}
