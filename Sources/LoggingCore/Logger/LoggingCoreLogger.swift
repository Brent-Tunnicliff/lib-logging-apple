// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation

/// Simple Logger for the Logging package to capture some of the extra work it does.
///
/// Works similar to the `Logging/DefaultLogger` but simplified and only expected to be used rarely.
package protocol LoggingCoreLogger: InternalLogger {}

extension LoggingCoreLogger {
    package func debug(
        _ message: String,
        error: (any Error)? = nil,
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line
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

    package func info(
        _ message: String,
        error: (any Error)? = nil,
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line
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

    package func error(
        _ message: String,
        error: (any Error)? = nil,
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line
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

    package func critical(
        _ message: String,
        error: (any Error)? = nil,
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line
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

// MARK: - Logger

package enum Logger {
    private static var isRunningTests: Bool {
        ProcessInfo.processInfo.processName == "xctest"
    }

    /// Logging for the package to use when useful.
    ///
    /// - Warning: Be careful when to call this within ``LoggingService`` or ``SystemLogger``,
    /// if handled when logs are sent it could become an infinite loop of logging events.
    package static let logging: any LoggingCoreLogger = {
        guard isRunningTests else {
            return DefaultLoggingCoreLogger(packageName: "logging")
        }

        return NoOpLoggingCoreLogger()
    }()
}

final class DefaultLoggingCoreLogger: LoggingCoreLogger {
    private let loggingService: any LoggingService
    private let packageName: String
    private let systemLogger: any InternalLogger

    convenience init(packageName: String) {
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

    func log(level: LogLevel, _ message: String, tag: LogTag, error: (any Error)?) {
        let timestamp = Date()
        systemLogger.log(level: level, message, tag: tag, error: error)

        Task {
            await loggingService.storeLog(
                error: error,
                logLevel: level,
                message: message,
                packageName: packageName,
                tag: tag,
                timestamp: timestamp
            )
        }
    }
}

private final class NoOpLoggingCoreLogger: LoggingCoreLogger {
    func log(level: LogLevel, _ message: String, tag: LogTag, error: (any Error)?) {}
}
