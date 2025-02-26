// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation
import Logging

extension Logger {
    static let app: any LoggerType = PersistentLogger(packageName: Bundle.main.bundleIdentifier!)
    static let other: any LoggerType = PersistentLogger(packageName: "other_logger")
}
