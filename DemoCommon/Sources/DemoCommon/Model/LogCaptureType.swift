// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import SwiftUICore

enum LogCaptureType: CaseIterable, Hashable {
    case once
    case scheduled
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
        case .scheduled:
            Text(
                "log_capture_type_label_scheduled",
                bundle: .module,
                comment: "The log will be scheduled to happen on a loop."
            )
        }
    }
}
