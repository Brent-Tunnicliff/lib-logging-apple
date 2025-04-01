// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

// Needs to be `@objc` so UserDefaults can make it a publisher.
@objc
enum LogLevel: Int {
    case debug = 0
    case info = 1
    case error = 2
    case critical = 3
}

extension LogLevel {
    var allowedLevels: [LogLevel] {
        LogLevel.allCases.filter {
            $0.rawValue >= self.rawValue
        }
    }
}

// MARK: - CaseIterable

extension LogLevel: CaseIterable {}

// MARK: - Comparable

extension LogLevel: Comparable {
    static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

// MARK: - CustomStringConvertible

extension LogLevel: CustomStringConvertible {
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
    #if DEBUG
        static let `default` = LogLevel.debug
    #else
        static let `default` = LogLevel.info
    #endif
}

// MARK: - Equatable

extension LogLevel: Equatable {}

// MARK: - Hashable

extension LogLevel: Hashable {}

// MARK: - Sendable

extension LogLevel: Sendable {}
