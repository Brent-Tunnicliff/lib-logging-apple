// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation

extension Notification.Name {
    static func mock(name: String? = nil) -> Notification.Name {
        Notification.Name(
            [
                "mockNotification",
                name,
            ]
            .compactMap { $0 }
            .joined(separator: "-")
        )
    }
}
