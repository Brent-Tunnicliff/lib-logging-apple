// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

/// Handles the management of logs in a Sendable, thread safe way.
public protocol Logger: Sendable {
    func log(level: LogLevel, _ message: String, tag: LogTag, error: (any Error)?)
}

extension Logger {
    /// Convenient wrapper to send a debug log.
    public func debug(_ message: String, tag: LogTag = LogTag(), error: (any Error)? = nil) {
        log(level: .debug, message, tag: tag, error: error)
    }

    /// Convenient wrapper to send a info log.
    public func info(_ message: String, tag: LogTag = LogTag(), error: (any Error)? = nil) {
        log(level: .info, message, tag: tag, error: error)
    }

    /// Convenient wrapper to send a error log.
    public func error(_ message: String, tag: LogTag = LogTag(), error: (any Error)? = nil) {
        log(level: .error, message, tag: tag, error: error)
    }

    /// Convenient wrapper to send a critical log.
    public func critical(_ message: String, tag: LogTag = LogTag(), error: (any Error)? = nil) {
        log(level: .critical, message, tag: tag, error: error)
    }
}
