// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation
import LoggingCore
import Synchronization

final class MockDateProvider: DateProvider {
    static let defaultDate: Date = {
        let dateString = "2025-01-01T00:00:00Z"

        do {
            return try Date.ISO8601FormatStyle().parse(dateString)
        } catch {
            preconditionFailure("Failed to parse date '\(dateString)' with error: \(error)")
        }
    }()

    private let nowMutex = Mutex(defaultDate)
    var now: Date {
        get { nowMutex.withLock { $0 } }
        set { nowMutex.withLock { $0 = newValue } }
    }
}
