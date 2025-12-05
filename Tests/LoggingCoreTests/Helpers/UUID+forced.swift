// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation

extension UUID {
    /// Returns a UUID based in the input string.
    ///
    /// - Parameter uuidString: String representing a date in ISO8601 format.
    /// - Returns: A valid date object matching the input.
    /// - Throws: Throws if the input is in an invalid format not recognised by `ISO8601DateFormatter`.
    static func forced(uuidString: String) throws(UUID.ForcedError) -> UUID {
        guard let id = UUID(uuidString: uuidString) else {
            throw ForcedError.unableToParseUUID(uuidString)
        }

        return id
    }

    enum ForcedError: Error {
        case unableToParseUUID(String)
    }
}
