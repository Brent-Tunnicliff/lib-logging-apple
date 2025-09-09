// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation
import Logging

enum Logger {
    private static var bundleIdentifier: String {
        guard let bundleIdentifier = Bundle.main.bundleIdentifier else {
            preconditionFailure("Unexpected nil Bundle.main.bundleIdentifier")
        }

        return bundleIdentifier
    }

    static let app: any LoggerType = DefaultLogger(packageName: bundleIdentifier)
    static let other: any LoggerType = DefaultLogger(packageName: "other")
}
