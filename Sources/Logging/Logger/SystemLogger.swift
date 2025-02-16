// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation
import os

final class SystemLogger {
    private let logger: os.Logger

    init(packageName: String) {
        self.logger = os.Logger(subsystem: Bundle.main.bundleIdentifier ?? "unknown", category: packageName)
    }
}

// MARK: - Logger

extension SystemLogger: Logger {
    func log(level: LogLevel, _ message: String, tag: LogTag, error: (any Error)?) {
        let errorMessage = error.map { ", error: \($0) (\($0.localizedDescription))" } ?? ""

        logger.log(
            level: level.osLogType,
            "[\(tag, privacy: .public)] \(message, privacy: .auto(mask: .hash))\(errorMessage, privacy: .auto(mask: .hash))"
        )
    }
}

// MARK: - Helpers

extension LogLevel {
    fileprivate var osLogType: OSLogType {
        switch wrapped {
        case .debug: .debug
        case .info: .default
        case .error: .error
        case .critical: .fault
        }
    }
}
