// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import LoggingCore

extension LogLevel {
    var asEntity: LogEntity.LogLevel {
        switch self {
        case .debug: .debug
        case .info: .info
        case .error: .error
        case .critical: .critical
        }
    }
}
