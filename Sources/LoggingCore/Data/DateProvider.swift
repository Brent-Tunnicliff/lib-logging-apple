// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

package import Foundation

package protocol DateProvider: Sendable {
    /// Returns a `Date` initialized to the current date and time.
    var now: Date { get }
}

extension DateProvider {
    /// Return a new `Date` by adding a `TimeInterval` to `now`.
    package func now(adding timeInterval: TimeInterval) -> Date {
        now.addingTimeInterval(timeInterval)
    }

    /// Return a new `Date` by adding a `Duration` to `now`.
    package func now(adding duration: Duration) -> Date {
        now(adding: duration.asTimeInterval)
    }

    /// Return a new `Date` by subtracting a `TimeInterval` from `now`.
    package func now(subtracting timeInterval: TimeInterval) -> Date {
        now.addingTimeInterval(-timeInterval)
    }

    /// Return a new `Date` by subtracting a `Duration` from `now`.
    package func now(subtracting duration: Duration) -> Date {
        now(subtracting: duration.asTimeInterval)
    }
}

package final class DefaultDateProvider: DateProvider {
    // It isn't vital for this to be a shared variable.
    // But it is used in a static variable already and initialising a new one in several places feels wasteful.
    package static let shared = DefaultDateProvider()

    package var now: Date {
        Date.now
    }

    private init() {}
}
