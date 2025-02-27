// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

/// Handles the management of logs in a Sendable, thread safe way.
public protocol LoggerType: Sendable {
    /// Captures  the inputs as a log.
    func log(level: LogLevel, _ message: String, tag: LogTag, error: (any Error)?)
}

extension LoggerType {
    /// Convenient wrapper to capture a debug log.
    public func debug(
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

    /// Convenient wrapper to capture a info log.
    public func info(
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

    /// Convenient wrapper to capture a error log.
    public func error(
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

    /// Convenient wrapper to capture a critical log.
    public func critical(
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
