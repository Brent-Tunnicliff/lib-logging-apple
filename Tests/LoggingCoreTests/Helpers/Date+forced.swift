// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation

extension Date {
    /// Returns a Date based in the input string.
    ///
    /// - Parameter string: String representing a date in ISO8601 format.
    /// - Returns: A valid date object matching the input.
    /// - Throws: Throws if the input is in an invalid format not recognised by `ISO8601DateFormatter`.
    static func forced(string: String) throws(Date.ForcedError) -> Date {
        guard let date = ISO8601DateFormatter().date(from: string) else {
            throw ForcedError.unableToParseDate(string)
        }

        return date
    }

    enum ForcedError: Error {
        case unableToParseDate(String)
    }
}
