// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

package import LoggingCore
import Synchronization

/// Mock Logger for use in tests and previews or where needed.
package final class MockLogger: InternalLogger {
    package init() {}

    // MARK: - log

    package struct LogInput {
        package let level: LogLevel
        package let message: String
        package let tag: LogTag
        package let error: (any Error)?
    }
    package typealias LogResponse = @Sendable (LogInput) -> Void
    private let logResponseMutex = Mutex<LogResponse>({ _ in })
    package var logResponse: LogResponse {
        get { logResponseMutex.withLock { $0 } }
        set { logResponseMutex.withLock { $0 = newValue } }
    }
    package func log(
        level: LogLevel,
        _ message: String,
        tag: LogTag,
        error: (any Error)?
    ) {
        logResponse(
            LogInput(
                level: level,
                message: message,
                tag: tag,
                error: error
            )
        )
    }
}

// MARK: - LoggerType

extension MockLogger: LoggerType {
    package func debug(
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

    package func info(
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

    package func error(
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

    package func critical(
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
