// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation
import Logging

enum Logger {
    nonisolated private static var bundleIdentifier: String {
        guard let bundleIdentifier = Bundle.main.bundleIdentifier else {
            preconditionFailure("Unexpected nil Bundle.main.bundleIdentifier")
        }

        return bundleIdentifier
    }

    // Not erasing type to `LoggerType` as we want to force trigger save.
    nonisolated static let app = DefaultLogger(packageName: bundleIdentifier)
    nonisolated static let other: any LoggerType = DefaultLogger(packageName: "other")
}
