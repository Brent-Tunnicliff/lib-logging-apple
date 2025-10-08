// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation
import LoggingCore

/// Logger that persists logs to disk and sends logs to the system console.
public final class DefaultLogger {
    private let dateProvider: any DateProvider
    private let loggingService: any LoggingService
    private let packageName: String
    private let systemLogger: any InternalLogger

    /// Initialises an instance of ``DefaultLogger`` with the defined package name.
    ///
    /// - Parameter packageName: Unique name to give the logger. Each log sent via this logger will be tagged with the packageName.
    public convenience init(packageName: String) {
        self.init(
            dateProvider: DefaultDateProvider.shared,
            loggingService: DefaultLoggingService.shared,
            packageName: packageName,
            systemLogger: SystemLogger(packageName: packageName)
        )
    }

    init(
        dateProvider: any DateProvider,
        loggingService: any LoggingService,
        packageName: String,
        systemLogger: any InternalLogger
    ) {
        self.dateProvider = dateProvider
        self.loggingService = loggingService
        self.packageName = packageName
        self.systemLogger = systemLogger
    }
}

// MARK: - InternalLogger

extension DefaultLogger: InternalLogger {
    func log(level: LoggingCore.LogLevel, message: String, tag: LogTag, error: (any Error)?) {
        let timestamp = dateProvider.now
        let thread = Thread.nameForLog
        systemLogger.log(level: level, message: message, tag: tag, error: error)

        Task {
            await loggingService.storeLog(
                error: error,
                logLevel: level,
                message: message,
                packageName: packageName,
                tag: tag,
                timestamp: timestamp,
                thread: thread
            )
        }
    }
}

// MARK: - LoggerType

extension DefaultLogger: LoggerType {
    /// Captures the inputs as a log.
    ///
    /// Recommended to use the extension functions that use default values instead.
    ///
    /// - Parameters:
    ///     - level: severity level of the log.
    ///     - message: message to log.
    ///     - error: optional error object to include in the log.
    ///     - file: File of where the log was triggered.
    ///     - function: Function name where the log was triggered.
    ///     - line: Line of where the log was triggered.
    public func log(
        level: LogLevel,
        message: String,
        error: (any Error)?,
        file: StaticString,
        function: StaticString,
        line: UInt
    ) {
        log(
            level: level.wrapped,
            message: message,
            tag: LogTag(
                file: file,
                function: function,
                line: line
            ),
            error: error
        )
    }
}
