// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import LoggingCore
import Synchronization

@testable import Logging

/// Mock Logger for use in tests and previews or where needed.
final class MockLogger: InternalLogger {
    // MARK: - log

    struct LogInput {
        let level: LoggingCore.LogLevel
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
        level: LoggingCore.LogLevel,
        message: String,
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
    func log(
        level: Logging.LogLevel,
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
