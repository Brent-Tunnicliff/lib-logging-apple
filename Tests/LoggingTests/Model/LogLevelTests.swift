// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Testing

@testable import Logging

struct LogLevelTests {
    // Manually defining the mappings to also make sure that every RawValue case has a matching static constant.
    private static let expectedLogLevelMappings: [LogLevel: LogLevel.Wrapped] = [
        .debug: .debug,
        .info: .info,
        .error: .error,
        .critical: .critical,
    ]

    @Test(arguments: LogLevel.allCases)
    func logLevelAllCases(logLevel: LogLevel) {
        let expectedValue = Self.expectedLogLevelMappings[logLevel]
        #expect(logLevel.wrapped == expectedValue)
    }

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

    @Test(arguments: LogLevel.allCases)
    func descriptionMatchesWrapped(logLevel: LogLevel) {
        #expect(logLevel.description == logLevel.wrapped.description)
    }
}
