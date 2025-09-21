// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation

@testable import LoggingCore

extension Device {
    /// Create a mock instance of ``Device``.
    static func mock(
        identifierForVendor: UUID? = UUID(),
        model: String? = "iPhone",
        systemName: String? = "iOS",
        systemVersion: String? = "18.3",
        userInterfaceIdiom: UserInterfaceIdiom = .phone
    ) -> Device {
        Device(
            identifierForVendor: identifierForVendor,
            model: model,
            systemName: systemName,
            systemVersion: systemVersion,
            userInterfaceIdiom: userInterfaceIdiom
        )
    }
}
