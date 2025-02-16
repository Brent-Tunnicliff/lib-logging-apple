// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

/// Represents the importance level of the log.
public struct LogLevel {
    let wrapped: LogLevel.Wrapped

    static let debug = LogLevel(wrapped: .debug)
    static let info = LogLevel(wrapped: .info)
    static let error = LogLevel(wrapped: .error)
    static let critical = LogLevel(wrapped: .critical)
}

extension LogLevel {
    @objc
    enum Wrapped: Int {
        case debug = 0
        case info = 1
        case error = 2
        case critical = 3
    }
}

// MARK: - CaseIterable

extension LogLevel: CaseIterable {
    /// A collection of all values of this type.
    public static let allCases: [LogLevel] = LogLevel.Wrapped.allCases.map(LogLevel.init)
}

extension LogLevel.Wrapped: CaseIterable {}

// MARK: - Comparable

extension LogLevel: Comparable {
    /// Returns a Boolean value indicating whether the value of the first
    /// argument is less than that of the second argument.
    public static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        lhs.wrapped < rhs.wrapped
    }
}

extension LogLevel.Wrapped: Comparable {
    static func < (lhs: LogLevel.Wrapped, rhs: LogLevel.Wrapped) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

// MARK: - CustomStringConvertible

extension LogLevel: CustomStringConvertible {
    /// A textual representation of this instance.
    public var description: String {
        wrapped.description
    }
}

extension LogLevel.Wrapped: CustomStringConvertible {
    var description: String {
        switch self {
        case .debug: "debug"
        case .info: "info"
        case .error: "error"
        case .critical: "critical"
        }
    }
}

// MARK: - Default

extension LogLevel {
    /// Default log level captured by the system.
    ///
    /// Debug builds will return `debug`, all others will return `info`.
    public static let `default` = LogLevel(wrapped: .default)
}

extension LogLevel.Wrapped {
    #if DEBUG
        static let `default` = LogLevel.Wrapped.debug
    #else
        static let `default` = LogLevel.Wrapped.info
    #endif
}

// MARK: - Equatable

extension LogLevel: Equatable {}
extension LogLevel.Wrapped: Equatable {}

// MARK: - Hashable

extension LogLevel: Hashable {}
extension LogLevel.Wrapped: Hashable {}

// MARK: - Sendable

extension LogLevel: Sendable {}
extension LogLevel.Wrapped: Sendable {}
