// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import LoggingCore
import SwiftUI

extension LogEntity.LogLevel {
    var label: Text {
        Text(stringResource)
    }

    var stringResource: LocalizedStringResource {
        switch self {
        case .debug: .LogLevel.debug
        case .info: .LogLevel.info
        case .error: .LogLevel.error
        case .critical: .LogLevel.critical
        }
    }
}
