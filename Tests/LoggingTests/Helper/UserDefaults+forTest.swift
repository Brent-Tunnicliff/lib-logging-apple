// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation

extension UserDefaults {
    static func forTest(
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt8 = #line
    ) -> UserDefaults {
        let suiteName = "\(UUID().uuidString)-\(file)-\(function)-\(line)"
        guard let userDefaults = UserDefaults(suiteName: suiteName) else {
            preconditionFailure("Failed to create UserDefaults with suiteName '\(suiteName)'")
        }

        // The odds of existing data is very low, but clearing all keys just in case.
        for key in userDefaults.dictionaryRepresentation().keys {
            userDefaults.removeObject(forKey: key)
        }

        return userDefaults
    }
}
