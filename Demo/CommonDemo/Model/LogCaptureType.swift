// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import SwiftUI

enum LogCaptureType: CaseIterable, Hashable {
    case once
    case everySecond
    case everyFiveSeconds
    case everyTenSeconds
}

extension LogCaptureType {
    var scheduledSeconds: TimeInterval? {
        switch self {
        case .once:
            nil
        case .everySecond:
            1
        case .everyFiveSeconds:
            5
        case .everyTenSeconds:
            10
        }
    }
}

// MARK: - View

extension LogCaptureType {
    var label: Text {
        switch self {
        case .once:
            Text(.logCaptureTypeLabelOnce)
        case .everySecond:
            Text(.logCaptureTypeLabelEverySecond)
        case .everyFiveSeconds:
            Text(.logCaptureTypeLabelEveryFiveSeconds)
        case .everyTenSeconds:
            Text(.logCaptureTypeLabelEveryTenSeconds)
        }
    }
}
