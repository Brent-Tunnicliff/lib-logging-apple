// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

public protocol Logger: Sendable {
    func log(level: LogLevel, _ message: String, tag: LogTag, error: (any Error)?)
}

extension Logger {
    public func debug(_ message: String, tag: LogTag = LogTag(), error: (any Error)? = nil) {
        log(level: .debug, message, tag: tag, error: error)
    }

    public func info(_ message: String, tag: LogTag = LogTag(), error: (any Error)? = nil) {
        log(level: .info, message, tag: tag, error: error)
    }

    public func error(_ message: String, tag: LogTag = LogTag(), error: (any Error)? = nil) {
        log(level: .error, message, tag: tag, error: error)
    }

    public func critical(_ message: String, tag: LogTag = LogTag(), error: (any Error)? = nil) {
        log(level: .critical, message, tag: tag, error: error)
    }
}
