// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation
import Testing

@testable import LoggingCore

@Suite("TimeInterval+initTests")
struct TimeIntervalInitTests {
    @Test()
    func durationMapsToTimeInterval() {
        let seconds = 123
        let expectedResult: TimeInterval = Double(seconds)
        let duration = Duration.seconds(seconds)
        let timeInterval = TimeInterval(duration: duration)
        #expect(timeInterval == expectedResult)
    }
}
