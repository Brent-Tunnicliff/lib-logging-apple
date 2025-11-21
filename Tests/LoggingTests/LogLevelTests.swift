// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Logging
import LoggingCore
import Testing

/// Tests to make sure it is wrapping the internal LogLevel values.
struct LogLevelTests {
    @Test(arguments: LoggingCore.LogLevel.allCases)
    func wrapsInternalLogLevel(logLevel: LoggingCore.LogLevel) {
        let publicLogLevel = logLevel.expectedWrapper
        #expect(publicLogLevel.description == logLevel.rawValue)
    }
}

extension LoggingCore.LogLevel {
    fileprivate var expectedWrapper: Logging.LogLevel {
        // This is the main point of the test,
        // to make sure at compile time that each internal log level has a public one to go with.
        switch self {
        case .debug: .debug
        case .info: .info
        case .error: .error
        case .critical: .critical
        }
    }
}
