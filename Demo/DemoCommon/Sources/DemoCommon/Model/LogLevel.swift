// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import SwiftUI

enum LogLevel: CaseIterable {
    case debug
    case info
    case error
    case critical
}

// MARK: - View

extension LogLevel {
    var label: Text {
        switch self {
        case .debug: .LogLevel.debug
        case .info: .LogLevel.info
        case .error: .LogLevel.error
        case .critical: .LogLevel.critical
        }
    }
}
