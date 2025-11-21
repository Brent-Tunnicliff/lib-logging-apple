// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Combine
import Foundation

protocol UserDefaultsStore: AnyObject {
    var minimalLogLevel: LogLevel { get set }
    var lastLogCleanup: Date? { get set }
}

extension UserDefaults: UserDefaultsStore {
    private var keyPrefix: String { "dev_tunnicliff_lib_logging" }

    // MARK: - minimalLogLevel

    // This key needs to match the one defined in `LoggingUI/Settings.bundle`.
    private var minimalLogLevelKey: String { "\(keyPrefix)_minimal_log_level" }
    var minimalLogLevel: LogLevel {
        get {
            // not using `integer(forKey:)` as we do not want it to default to 0.
            guard
                let value = string(forKey: minimalLogLevelKey),
                let logLevel = LogLevel(rawValue: value)
            else {
                // This default value needs to match the one defined in `LoggingUI/Settings.bundle`.
                return .info
            }

            return logLevel
        }
        set {
            setValue(newValue.rawValue, forKey: minimalLogLevelKey)
        }
    }

    // MARK: - lastLogCleanup

    private var lastLogCleanupKey: String { "\(keyPrefix)_last_log_cleanup" }
    var lastLogCleanup: Date? {
        get {
            value(forKey: lastLogCleanupKey) as? Date
        }
        set {
            setValue(newValue, forKey: lastLogCleanupKey)
        }
    }
}
