// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation

extension UserDefaults {
    @objc dynamic var logLevel: LogLevel {
        get {
            // not using `integer(forKey:)` as we do not want it to default to 0.
            guard let value = value(forKey: #function) as? Int, let logLevel = LogLevel(rawValue: value) else {
                return .default
            }

            return logLevel
        }
        set {
            setValue(newValue.rawValue, forKey: #function)
        }
    }
}
