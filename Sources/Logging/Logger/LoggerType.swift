// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

/// Handles the management of logs in a Sendable, thread safe way.
public protocol LoggerType: Sendable {
    /// Captures the inputs as a debug level log.
    ///
    /// - Parameters:
    ///     - message: message to log.
    ///     - error: optional error object to include in the log.
    ///     - file: File of where the log was triggered.
    ///     - function: Function name where the log was triggered.
    ///     - line: Line of where the log was triggered.
    func debug(_ message: String, error: (any Error)?, file: StaticString, function: StaticString, line: UInt)

    /// Captures the inputs as a info level log.
    ///
    /// - Parameters:
    ///     - message: message to log.
    ///     - error: optional error object to include in the log.
    ///     - file: File of where the log was triggered.
    ///     - function: Function name where the log was triggered.
    ///     - line: Line of where the log was triggered.
    func info(_ message: String, error: (any Error)?, file: StaticString, function: StaticString, line: UInt)

    /// Captures the inputs as an error level log.
    ///
    /// - Parameters:
    ///     - message: message to log.
    ///     - error: optional error object to include in the log.
    ///     - file: File of where the log was triggered.
    ///     - function: Function name where the log was triggered.
    ///     - line: Line of where the log was triggered.
    func error(_ message: String, error: (any Error)?, file: StaticString, function: StaticString, line: UInt)

    /// Captures the inputs as a critical level log.
    ///
    /// - Parameters:
    ///     - message: message to log.
    ///     - error: optional error object to include in the log.
    ///     - file: File of where the log was triggered.
    ///     - function: Function name where the log was triggered.
    ///     - line: Line of where the log was triggered.
    func critical(_ message: String, error: (any Error)?, file: StaticString, function: StaticString, line: UInt)
}

// MARK: - Default implementations

extension LoggerType {
    /// Captures the inputs as a debug level log.
    ///
    /// - Parameters:
    ///     - message: message to log.
    ///     - error: optional error object to include in the log. Defaults to `nil`.
    ///     - file: File of where the log was triggered. Defaults to `#file`.
    ///     - function: Function name where the log was triggered. Defaults to `#function`.
    ///     - line: Line of where the log was triggered. Defaults to `#line`.
    public func debug(
        _ message: String,
        error: (any Error)? = nil,
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        debug(message, error: error, file: file, function: function, line: line)
    }

    /// Captures the inputs as a info level log.
    ///
    /// - Parameters:
    ///     - message: message to log.
    ///     - error: optional error object to include in the log. Defaults to `nil`.
    ///     - file: File of where the log was triggered. Defaults to `#file`.
    ///     - function: Function name where the log was triggered. Defaults to `#function`.
    ///     - line: Line of where the log was triggered. Defaults to `#line`.
    public func info(
        _ message: String,
        error: (any Error)? = nil,
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        info(message, error: error, file: file, function: function, line: line)
    }

    /// Captures the inputs as an error level log.
    ///
    /// - Parameters:
    ///     - message: message to log.
    ///     - error: optional error object to include in the log. Defaults to `nil`.
    ///     - file: File of where the log was triggered. Defaults to `#file`.
    ///     - function: Function name where the log was triggered. Defaults to `#function`.
    ///     - line: Line of where the log was triggered. Defaults to `#line`.
    public func error(
        _ message: String,
        error: (any Error)? = nil,
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        self.error(message, error: error, file: file, function: function, line: line)
    }

    /// Captures the inputs as a critical level log.
    ///
    /// - Parameters:
    ///     - message: message to log.
    ///     - error: optional error object to include in the log. Defaults to `nil`.
    ///     - file: File of where the log was triggered. Defaults to `#file`.
    ///     - function: Function name where the log was triggered. Defaults to `#function`.
    ///     - line: Line of where the log was triggered. Defaults to `#line`.
    public func critical(
        _ message: String,
        error: (any Error)? = nil,
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        critical(message, error: error, file: file, function: function, line: line)
    }
}
