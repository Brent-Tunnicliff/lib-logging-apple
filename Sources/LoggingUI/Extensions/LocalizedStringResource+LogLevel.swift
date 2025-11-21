// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

public import SwiftUI

extension LocalizedStringResource {
    /// Labels for supported log levels.
    public enum LogLevel {
        /// Label for the debug log level.
        public static var debug: LocalizedStringResource {
            .logLevelDebug
        }

        /// Label for the info log level.
        public static var info: LocalizedStringResource {
            .logLevelInfo
        }

        /// Label for the error log level.
        public static var error: LocalizedStringResource {
            .logLevelError
        }

        /// Label for the critical log level.
        public static var critical: LocalizedStringResource {
            .logLevelCritical
        }
    }
}
