// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation
import os

/// Logger that captures to the OS logger.
public final class SystemLogger {
    private let logger: os.Logger

    /// Initialises an instance of ``SystemLogger`` with the defined package name.
    ///
    /// - Parameter packageName: Unique name to give the logger. Each log sent via this logger will be tagged with the packageName.
    public init(packageName: String) {
        self.logger = os.Logger(subsystem: Bundle.main.bundleIdentifier ?? "unknown", category: packageName)
    }
}

// MARK: - InternalLoggerType

extension SystemLogger: InternalLoggerType {
    /// Captures  the inputs as a log.
    func log(level: LogLevel, _ message: String, tag: LogTag, error: (any Error)?) {
        let errorMessage = error.map { ", error: \($0) (\($0.localizedDescription))" } ?? ""

        logger.log(
            level: level.osLogType,
            "[\(tag, privacy: .public)] \(message, privacy: .auto(mask: .hash))\(errorMessage, privacy: .auto(mask: .hash))"
        )
    }
}

// MARK: - LoggerType

extension SystemLogger: LoggerType {}

// MARK: - Helpers

extension LogLevel {
    fileprivate var osLogType: OSLogType {
        switch self {
        case .debug: .debug
        case .info: .default
        case .error: .error
        case .critical: .fault
        }
    }
}
