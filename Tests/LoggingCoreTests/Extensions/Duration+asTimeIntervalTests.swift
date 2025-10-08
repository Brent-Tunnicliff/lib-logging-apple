// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation
import Testing

@testable import LoggingCore

@Suite("Duration+asTimeIntervalTests")
struct DurationAsTimeInterval {
    @Test(arguments: AsTimeIntervalArgument.allCases)
    func asTimeInterval(_ argument: AsTimeIntervalArgument) {
        let duration = argument.duration
        let expectedResult = argument.expectedResult
        #expect(duration.asTimeInterval == expectedResult)
    }
}

// MARK: - Helpers

extension DurationAsTimeInterval {
    enum AsTimeIntervalArgument: CaseIterable {
        case nanosecond
        case microsecond
        case millisecond
        case second
        case secondAndHalf
        case minute
        case hour
        case day
    }
}

extension DurationAsTimeInterval.AsTimeIntervalArgument {
    var duration: Duration {
        switch self {
        case .nanosecond: .nanoseconds(1)
        case .microsecond: .microseconds(1)
        case .millisecond: .milliseconds(1)
        case .second: .seconds(1)
        case .secondAndHalf: .seconds(1.5)
        case .minute: .minutes(1)
        case .hour: .hours(1)
        case .day: .days(1)
        }
    }

    var expectedResult: TimeInterval {
        switch self {
        case .nanosecond: 0.000000001
        case .microsecond: 0.000001
        case .millisecond: 0.001
        case .second: 1
        case .secondAndHalf: 1.5
        case .minute: 60
        case .hour: 3600
        case .day: 86400
        }
    }
}
