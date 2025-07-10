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
            Text(
                "log_capture_type_label_once",
                bundle: .module,
                comment: "The log will only be sent one time."
            )
        case .everySecond:
            Text(
                "log_capture_type_label_every_second",
                bundle: .module,
                comment: "The log will be scheduled to happen on a loop every 1 second."
            )
        case .everyFiveSeconds:
            Text(
                "log_capture_type_label_every_five_seconds",
                bundle: .module,
                comment: "The log will be scheduled to happen on a loop every 5 seconds."
            )
        case .everyTenSeconds:
            Text(
                "log_capture_type_label_every_ten_seconds",
                bundle: .module,
                comment: "The log will be scheduled to happen on a loop every 5 seconds."
            )
        }
    }
}
