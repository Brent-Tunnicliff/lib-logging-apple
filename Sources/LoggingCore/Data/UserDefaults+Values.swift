// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Combine
import Foundation

protocol UserDefaultsStore: AnyObject {
    var lastLogCleanup: Date? { get set }
    var minimalLogLevel: LogLevel { get set }
    var viewCriticalLogs: Bool { get set }
    var viewDebugLogs: Bool { get set }
    var viewErrorLogs: Bool { get set }
    var viewInfoLogs: Bool { get set }
}

extension UserDefaults: UserDefaultsStore {
    private var keyPrefix: String { "dev_tunnicliff_lib_logging" }

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

    // MARK: - viewCriticalLogs

    private var viewCriticalLogsKey: String { "\(keyPrefix)_view_critical_logs" }
    @objc package dynamic var viewCriticalLogs: Bool {
        get {
            value(forKey: viewCriticalLogsKey) as? Bool ?? true
        }
        set {
            setValue(newValue, forKey: viewCriticalLogsKey)
        }
    }

    // MARK: - viewDebugLogs

    private var viewDebugLogsKey: String { "\(keyPrefix)_view_debug_logs" }
    @objc package dynamic var viewDebugLogs: Bool {
        get {
            value(forKey: viewDebugLogsKey) as? Bool ?? false
        }
        set {
            setValue(newValue, forKey: viewDebugLogsKey)
        }
    }

    // MARK: - viewErrorLogs

    private var viewErrorLogsKey: String { "\(keyPrefix)_view_error_logs" }
    @objc package dynamic var viewErrorLogs: Bool {
        get {
            value(forKey: viewErrorLogsKey) as? Bool ?? true
        }
        set {
            setValue(newValue, forKey: viewErrorLogsKey)
        }
    }

    // MARK: - viewInfoLogs

    private var viewInfoLogsKey: String { "\(keyPrefix)_view_info_logs" }
    @objc package dynamic var viewInfoLogs: Bool {
        get {
            value(forKey: viewInfoLogsKey) as? Bool ?? true
        }
        set {
            setValue(newValue, forKey: viewInfoLogsKey)
        }
    }
}
