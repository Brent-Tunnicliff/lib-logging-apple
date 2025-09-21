// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Logging
import LoggingCore
import Synchronization

/// Mock Logger for use in tests and previews or where needed.
final class MockLogger: InternalLogger {
    // MARK: - log

    struct LogInput {
        let level: LogLevel
        let message: String
        let tag: LogTag
        let error: (any Error)?
    }
    typealias LogResponse = @Sendable (LogInput) -> Void
    private let logResponseMutex = Mutex<LogResponse>({ _ in })
    var logResponse: LogResponse {
        get { logResponseMutex.withLock { $0 } }
        set { logResponseMutex.withLock { $0 = newValue } }
    }
    func log(
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
    func debug(
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

    func info(
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

    func error(
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

    func critical(
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
