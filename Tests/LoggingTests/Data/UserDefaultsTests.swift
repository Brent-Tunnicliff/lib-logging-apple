// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation
import Testing

@testable import Logging

struct UserDefaultsTests {
    private let userDefaults = UserDefaults.forTest()

    @Test(arguments: LogLevel.allCases)
    func logLevel(_ value: LogLevel) {
        #expect(userDefaults.minimalLogLevel == .default)
        userDefaults.minimalLogLevel = value
        #expect(userDefaults.minimalLogLevel == value)
    }
}
