// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation

/// Logger that persists logs to disk.
public final class PersistentLogger {
    private let loggingService: any LoggingService
    private let packageName: String
    private let systemLogger: any LoggerType

    public convenience init(packageName: String) {
        self.init(
            loggingService: DefaultLoggingService.shared,
            packageName: packageName,
            systemLogger: SystemLogger(packageName: packageName)
        )
    }

    init(
        loggingService: any LoggingService,
        packageName: String,
        systemLogger: any LoggerType
    ) {
        self.loggingService = loggingService
        self.packageName = packageName
        self.systemLogger = systemLogger
    }
}

// MARK: - LoggerType

extension PersistentLogger: LoggerType {
    /// Captures  the inputs as a log.
    public func log(level: LogLevel, _ message: String, tag: LogTag, error: (any Error)?) {
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
