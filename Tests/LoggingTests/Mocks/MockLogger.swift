// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Logging
import LoggingCore

@MainActor
final class MockLogger: LoggerType, InternalLogger {
    var logCompletionHandler: @Sendable () -> Void = {}
    var logCalled: Bool { !logInputs.isEmpty }
    typealias LogInputsType = (
        level: LogLevel,
        message: String,
        tag: LogTag,
        error: (any Error)?
    )
    private(set) var logInputs: [LogInputsType] = []
    nonisolated func log(
        level: LogLevel,
        _ message: String,
        tag: LogTag,
        error: (any Error)?
    ) {
        Task { @MainActor in
            defer {
                logCompletionHandler()
            }

            logInputs.append((level, message, tag, error))
        }
    }

    nonisolated func debug(
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

    nonisolated func info(
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

    nonisolated func error(
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

    nonisolated func critical(
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
