// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

protocol InternalLoggerType: LoggerType {
    /// Captures  the inputs as a log.
    func log(
        level: LogLevel,
        _ message: String,
        tag: LogTag,
        error: (any Error)?
    )
}

extension InternalLoggerType {
    /// Captures the inputs as a debug level log.
    ///
    /// - Parameters:
    ///     - message: message to log.
    ///     - error: optional error object to include in the log.
    ///     - file: File of where the log was triggered.
    ///     - function: Function name where the log was triggered.
    ///     - line: Line of where the log was triggered.
    public func debug(
        _ message: String,
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
        _ message: String,
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
        _ message: String,
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
        _ message: String,
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
