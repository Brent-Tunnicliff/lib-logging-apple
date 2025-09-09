// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

// Needs to be `@objc` so UserDefaults can make it a publisher.
@objc
package enum LogLevel: Int {
    case debug = 0
    case info = 1
    case error = 2
    case critical = 3
}

// MARK: - CaseIterable

extension LogLevel: CaseIterable {}

// MARK: - Comparable

extension LogLevel: Comparable {
    package static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        lhs.order < rhs.order
    }

    private var order: Int {
        // For now `rawValue` matches the order.
        rawValue
    }
}

// MARK: - CustomStringConvertible

extension LogLevel: CustomStringConvertible {
    package var description: String {
        switch self {
        case .debug: "debug"
        case .info: "info"
        case .error: "error"
        case .critical: "critical"
        }
    }
}

// MARK: - Equatable

extension LogLevel: Equatable {}

// MARK: - Hashable

extension LogLevel: Hashable {}

// MARK: - Sendable

extension LogLevel: Sendable {}
