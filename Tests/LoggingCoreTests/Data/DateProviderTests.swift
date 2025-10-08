// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation
import Testing

@testable import LoggingCore

struct DateProviderTests {
    // Just double checking that `DefaultDateProvider` really is returning 'now' and not a mocked value.
    @Test
    func now() {
        let before = Date()
        let dateProvider = DefaultDateProvider.shared
        let now = dateProvider.now
        let after = Date()

        #expect(now >= before, "Expect 'now' to be greater than or equal to the date before we call it")
        #expect(now <= after, "Expect 'now' to be less than or equal to the date after we call it")
    }

    @Test
    func nowAddingTimeInterval() throws {
        let dateProvider = MockDateProvider()
        let timeInterval: TimeInterval = 123_456
        let expectedResult = try Date.ISO8601FormatStyle().parse("2025-01-02T10:17:36Z")
        #expect(dateProvider.now(adding: timeInterval) == expectedResult)
    }

    @Test
    func nowAddingDuration() throws {
        let dateProvider = MockDateProvider()
        let duration = Duration.seconds(123_456)
        let expectedResult = try Date.ISO8601FormatStyle().parse("2025-01-02T10:17:36Z")
        #expect(dateProvider.now(adding: duration) == expectedResult)
    }

    @Test
    func nowSubtractingTimeInterval() throws {
        let dateProvider = MockDateProvider()
        let timeInterval: TimeInterval = 123_456
        let expectedResult = try Date.ISO8601FormatStyle().parse("2024-12-30T13:42:24Z")
        #expect(dateProvider.now(subtracting: timeInterval) == expectedResult)
    }

    @Test
    func nowSubtractingDuration() throws {
        let dateProvider = MockDateProvider()
        let duration = Duration.seconds(123_456)
        let expectedResult = try Date.ISO8601FormatStyle().parse("2024-12-30T13:42:24Z")
        #expect(dateProvider.now(subtracting: duration) == expectedResult)
    }
}
