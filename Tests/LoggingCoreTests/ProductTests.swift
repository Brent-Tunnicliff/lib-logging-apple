// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import LoggingCore
import Testing

struct ProductTests {
    @Test
    func productWorksAsExpected() {
        let first = [1, 2, 3]
        let second = ["a", "b", "c"]
        let expectedResult = [
            (1, "a"),
            (1, "b"),
            (1, "c"),
            (2, "a"),
            (2, "b"),
            (2, "c"),
            (3, "a"),
            (3, "b"),
            (3, "c"),
        ]

        #expect(product(first, second) == expectedResult)
    }
}

extension Array {
    fileprivate static func == <A: Equatable, B: Equatable>(
        lhs: [Element],
        rhs: [Element]
    ) -> Bool where Element == (A, B) {
        guard lhs.count == rhs.count else {
            return false
        }

        for (offset, element) in lhs.enumerated() where element != rhs[offset] {
            return false
        }

        return true
    }
}
