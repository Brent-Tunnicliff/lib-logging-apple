// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

package enum LogLevel: String {
    case debug
    case info
    case error
    case critical
}

extension LogLevel: CaseIterable {}
extension LogLevel: Equatable {}
extension LogLevel: Hashable {}
extension LogLevel: Sendable {}
