// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import LoggingCore
import SwiftUI

extension LogLevel {
    var label: LocalizedStringKey {
        switch self {
        case .debug: "log_level_debug"
        case .info: "log_level_info"
        case .error: "log_level_error"
        case .critical: "log_level_critical"
        }
    }
}
