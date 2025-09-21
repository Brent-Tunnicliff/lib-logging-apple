// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation
import Testing

@testable import LoggingCore

@Suite("Duration+largerTests")
struct DurationLargerTests {
    private let secondsInOneMinute = 60
    private var secondsInOneHour: Int { secondsInOneMinute * 60 }
    private var secondsInOneDay: Int { secondsInOneHour * 24 }

    private static let testArguments: [Int] = [
        -1_234_567,
        -1_000,
        -90,
        -26,
        -1,
        0,
        1,
        26,
        90,
        1_000,
        1_234_567,
    ]

    @Test(arguments: DurationLargerTests.testArguments)
    func minutes(_ minutes: Int) {
        let expectedResult: Int = secondsInOneMinute * minutes
        #expect(Duration.minutes(minutes).components.seconds == expectedResult)

        // Seperate function for handling Double vs Int
        let asDouble = Double(minutes)
        #expect(Duration.minutes(asDouble).components.seconds == expectedResult)
    }

    @Test(arguments: DurationLargerTests.testArguments)
    func hours(_ hours: Int) {
        let expectedResult: Int = secondsInOneHour * hours
        #expect(Duration.hours(hours).components.seconds == expectedResult)

        // Seperate function for handling Double vs Int
        let asDouble = Double(hours)
        #expect(Duration.hours(asDouble).components.seconds == expectedResult)
    }

    @Test(arguments: DurationLargerTests.testArguments)
    func days(_ days: Int) {
        let expectedResult: Int = secondsInOneDay * days
        #expect(Duration.days(days).components.seconds == expectedResult)

        // Seperate function for handling Double vs Int
        let asDouble = Double(days)
        #expect(Duration.days(asDouble).components.seconds == expectedResult)
    }
}
