// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import LoggingCore

/// The severity level of logs.
public struct LogLevel {
    let wrapped: LoggingCore.LogLevel

    private init(wrapped: LoggingCore.LogLevel) {
        self.wrapped = wrapped
    }
}

// MARK: - Values

extension LogLevel {
    /// Debug severity level.
    public static let debug: LogLevel = LogLevel(wrapped: .debug)

    /// Info severity level.
    public static let info: LogLevel = LogLevel(wrapped: .info)

    /// Error severity level.
    public static let error: LogLevel = LogLevel(wrapped: .error)

    /// Critical severity level.
    public static let critical: LogLevel = LogLevel(wrapped: .critical)
}

// MARK: - CustomStringConvertible

extension LogLevel: CustomStringConvertible {
    /// A textual representation of this instance.
    public var description: String {
        wrapped.rawValue
    }
}

// MARK: - Equatable

extension LogLevel: Equatable {}

// MARK: - Hashable

extension LogLevel: Hashable {}

// MARK: - Sendable

extension LogLevel: Sendable {}
