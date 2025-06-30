// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation

extension UserDefaults {
    // This key needs to match the one defined in `LoggingUI/Settings.bundle`.
    private static let minimalLogLevelKey = "logging_minimal_log_level"
    @objc dynamic var minimalLogLevel: LogLevel {
        get {
            // not using `integer(forKey:)` as we do not want it to default to 0.
            guard
                let value = value(forKey: Self.minimalLogLevelKey) as? Int,
                let logLevel = LogLevel(rawValue: value)
            else {
                // This default value needs to match the one defined in `LoggingUI/Settings.bundle`.
                return .info
            }

            return logLevel
        }
        set {
            setValue(newValue.rawValue, forKey: Self.minimalLogLevelKey)
        }
    }
}
