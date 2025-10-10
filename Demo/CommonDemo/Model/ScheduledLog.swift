// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation

struct ScheduledLog {
    let id: UUID
    let logLevel: LogLevel
    let message: String
    let error: (any Error)?
    let timestamp: Date
}

// MARK: - SortComparator

struct ScheduledLogSortComparator: SortComparator {
    var order: SortOrder = .forward

    func compare(_ lhs: ScheduledLog, _ rhs: ScheduledLog) -> ComparisonResult {
        guard lhs.timestamp != rhs.timestamp else {
            return lhs.id < rhs.id ? .orderedDescending : .orderedAscending
        }

        return lhs.timestamp < rhs.timestamp ? .orderedDescending : .orderedAscending
    }
}
