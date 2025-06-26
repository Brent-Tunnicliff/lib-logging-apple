// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation
import LoggingCore

/// Logger that persists logs to disk and sends logs to the system console.
public final class DefaultLogger {
    private let loggingService: any LoggingService
    private let packageName: String
    private let systemLogger: any InternalLogger

    /// Initialises an instance of ``DefaultLogger`` with the defined package name.
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
        loggingService: any LoggingService,
        packageName: String,
        systemLogger: any InternalLogger
    ) {
        self.loggingService = loggingService
        self.packageName = packageName
        self.systemLogger = systemLogger
    }
}

// MARK: - InternalLogger

extension DefaultLogger: InternalLogger {
    func log(level: LogLevel, _ message: String, tag: LogTag, error: (any Error)?) {
        let timestamp = Date()
        systemLogger.log(level: level, message, tag: tag, error: error)

        // Using `detached` as we never want this to be canceled with a parent task.
        // We always want logs to run until complete.
        Task.detached { [loggingService, packageName, systemLogger] in
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
                systemLogger.log(
                    level: .critical,
                    "Storing log failed: \(error)",
                    tag: LogTag(file: #file, function: #function, line: #line),
                    error: error
                )
            }
        }
    }
}

// MARK: - LoggerType

extension DefaultLogger: LoggerType {
    /// Captures the inputs as a debug level log.
    ///
    /// - Parameters:
    ///     - message: message to log.
    ///     - error: optional error object to include in the log.
    ///     - file: File of where the log was triggered.
    ///     - function: Function name where the log was triggered.
    ///     - line: Line of where the log was triggered.
    public func debug(
        message: String,
        error: (any Error)?,
        file: StaticString,
        function: StaticString,
        line: UInt
    ) {
        log(
            level: .debug,
            message,
            tag: LogTag(
                file: file,
                function: function,
                line: line
            ),
            error: error
        )
    }

    /// Captures the inputs as a info level log.
    ///
    /// - Parameters:
    ///     - message: message to log.
    ///     - error: optional error object to include in the log.
    ///     - file: File of where the log was triggered.
    ///     - function: Function name where the log was triggered.
    ///     - line: Line of where the log was triggered.
    public func info(
        message: String,
        error: (any Error)?,
        file: StaticString,
        function: StaticString,
        line: UInt
    ) {
        log(
            level: .info,
            message,
            tag: LogTag(
                file: file,
                function: function,
                line: line
            ),
            error: error
        )
    }

    /// Captures the inputs as an error level log.
    ///
    /// - Parameters:
    ///     - message: message to log.
    ///     - error: optional error object to include in the log.
    ///     - file: File of where the log was triggered.
    ///     - function: Function name where the log was triggered.
    ///     - line: Line of where the log was triggered.
    public func error(
        message: String,
        error: (any Error)?,
        file: StaticString,
        function: StaticString,
        line: UInt
    ) {
        log(
            level: .error,
            message,
            tag: LogTag(
                file: file,
                function: function,
                line: line
            ),
            error: error
        )
    }

    /// Captures the inputs as a critical level log.
    ///
    /// - Parameters:
    ///     - message: message to log.
    ///     - error: optional error object to include in the log.
    ///     - file: File of where the log was triggered.
    ///     - function: Function name where the log was triggered.
    ///     - line: Line of where the log was triggered.
    public func critical(
        message: String,
        error: (any Error)?,
        file: StaticString,
        function: StaticString,
        line: UInt
    ) {
        log(
            level: .critical,
            message,
            tag: LogTag(
                file: file,
                function: function,
                line: line
            ),
            error: error
        )
    }
}
