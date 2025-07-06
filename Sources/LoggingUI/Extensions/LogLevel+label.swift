// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import LoggingCore
public import SwiftUI

extension LogEntity.LogLevel {
    var label: Text {
        switch self {
        case .debug: .LogLevel.debug
        case .info: .LogLevel.info
        case .error: .LogLevel.error
        case .critical: .LogLevel.critical
        }
    }
}

extension Text {
    /// Text values for supported log levels.
    public enum LogLevel {
        /// Text label for the debug log level.
        public static var debug: Text {
            Text(
                "log_level_debug",
                bundle: .module,
                comment: "The log severity level - debug information."
            )
        }

        /// Text label for the info log level.
        public static var info: Text {
            Text(
                "log_level_info",
                bundle: .module,
                comment: "The log severity level - informative."
            )
        }

        /// Text label for the error log level.
        public static var error: Text {
            Text(
                "log_level_error",
                bundle: .module,
                comment: "The log severity level - error happened."
            )
        }

        /// Text label for the critical log level.
        public static var critical: Text {
            Text(
                "log_level_critical",
                bundle: .module,
                comment: "The log severity level - critical issue."
            )
        }
    }
}
