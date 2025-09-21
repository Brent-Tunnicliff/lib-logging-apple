// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation
import Testing

@testable import LoggingCore

/// The main purpose of these tests are to check the set and get are using the correct keys.
struct UserDefaultsTests {
    private let userDefaults = UserDefaults.forTest()

    @Test(arguments: LogLevel.allCases)
    func minimalLogLevel(_ value: LogLevel) {
        #expect(userDefaults.minimalLogLevel == .info)
        userDefaults.minimalLogLevel = value
        #expect(userDefaults.minimalLogLevel == value)
    }

    @Test
    func lastLogCleanup() {
        // Default value should be `nil`
        #expect(userDefaults.lastLogCleanup == nil)

        let value = Date()

        // Expect that the set and get are using the same key.
        userDefaults.lastLogCleanup = value
        #expect(userDefaults.lastLogCleanup == value)
    }
}
