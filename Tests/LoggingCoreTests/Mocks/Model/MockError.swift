// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation
import Testing

struct MockError: Error {
    private let id = UUID()
}

// MARK: - Equatable

extension MockError: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }

    // MARK: Helper types
    // Allows easy comparing with `any Error` types and optionals.

    static func == (lhs: (any Error)?, rhs: Self) -> Bool {
        guard let lhs = lhs as? Self else {
            return false
        }

        return lhs == rhs
    }

    static func == (lhs: any Error, rhs: Self) -> Bool {
        // Easier to wrap as Optional than redefine the logic
        Optional(lhs) == rhs
    }

    static func == (lhs: Self, rhs: any Error) -> Bool {
        // Easier to swap them than redefine the logic
        rhs == lhs
    }

    static func == (lhs: Self, rhs: (any Error)?) -> Bool {
        // Easier to swap them than redefine the logic
        rhs == lhs
    }
}

extension MockError: CustomStringConvertible, CustomDebugStringConvertible, CustomTestStringConvertible {
    // We compare the `MockError` description in some tests, so lock it in as a static value.
    var description: String {
        "MockError()"
    }

    var debugDescription: String {
        "MockError(id: \(id.uuidString)"
    }

    var testDescription: String {
        debugDescription
    }
}
