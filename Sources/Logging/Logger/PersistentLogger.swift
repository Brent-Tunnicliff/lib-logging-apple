// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation

/// Logger that persists logs to disk.
public final class PersistentLogger {
    private let loggingService: Task<any LoggingService, Never>
    private let packageName: String
    private let systemLogger: any InternalLoggerType

    /// Initialises an instance of ``PersistentLogger`` with the defined package name.
    ///
    /// - Parameter packageName: Unique name to give the logger. Each log sent via this logger will be tagged with the packageName.
    public convenience init(packageName: String) {
        self.init(
            loggingService: DefaultLoggingService.shared,
            packageName: packageName,
            systemLogger: SystemLogger(packageName: packageName)
        )
    }

    init(
        loggingService: Task<any LoggingService, Never>,
        packageName: String,
        systemLogger: any InternalLoggerType
    ) {
        self.loggingService = loggingService
        self.packageName = packageName
        self.systemLogger = systemLogger
    }
}

// MARK: - InternalLoggerType

extension PersistentLogger: InternalLoggerType {
    /// Captures  the inputs as a log.
    func log(level: LogLevel, _ message: String, tag: LogTag, error: (any Error)?) {
        let timestamp = Date()
        systemLogger.log(level: level, message, tag: tag, error: error)

        // Using `detached` as we never want this to be canceled with a parent task.
        // We always want logs to run until complete.
        Task.detached { [loggingService, packageName, systemLogger] in
            do {
                try await loggingService.value.storeLog(
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

// MARK: - LoggerType

extension PersistentLogger: LoggerType {}
