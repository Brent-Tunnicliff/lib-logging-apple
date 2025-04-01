// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Testing

@testable import Logging

struct LogLevelTests {
    @Test
    func sortOrder() {
        let expectedOrder: [LogLevel] = [
            .debug,
            .info,
            .error,
            .critical,
        ]

        #expect(LogLevel.allCases.sorted() == expectedOrder)
    }
}
