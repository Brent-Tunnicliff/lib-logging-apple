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
            Text(.logLevelDebug)
        }

        /// Text label for the info log level.
        public static var info: Text {
            Text(.logLevelInfo)
        }

        /// Text label for the error log level.
        public static var error: Text {
            Text(.logLevelError)
        }

        /// Text label for the critical log level.
        public static var critical: Text {
            Text(.logLevelCritical)
        }
    }
}
