// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation

extension Date {
    /// Returns a Date based in the input string.
    ///
    /// - Parameter string: String representing a date in ISO8601 format. If invalid will trigger a `preconditionFailure`
    static func forced(string: String) -> Date {
        guard let date = ISO8601DateFormatter().date(from: string) else {
            preconditionFailure("Unable to parse date: \(string)")
        }

        return date
    }
}
