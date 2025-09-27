// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

/// A  type of logger wit no operations, meaning it will drop all logs it receives.
///
/// Potentially useful to override the default logger when tests are running.
public final class NoOpLogger {
    /// Initialises an instance of ``NoOpLogger``.
    public init() {}
}

// MARK: - LoggerType

extension NoOpLogger: LoggerType {
    /// Conforms to LoggerType but will not capture any of these details.
    public func debug(message: String, error: (any Error)?, file: StaticString, function: StaticString, line: UInt) {}

    /// Conforms to LoggerType but will not capture any of these details.
    public func info(message: String, error: (any Error)?, file: StaticString, function: StaticString, line: UInt) {}

    /// Conforms to LoggerType but will not capture any of these details.
    public func error(message: String, error: (any Error)?, file: StaticString, function: StaticString, line: UInt) {}

    /// Conforms to LoggerType but will not capture any of these details.
    public func critical(
        message: String,
        error: (any Error)?,
        file: StaticString,
        function: StaticString,
        line: UInt
    ) {}
}
