// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation
import Logging
import SwiftUI

protocol LogSchedulerService: Sendable {
    func capture(logLevel: LogLevel, message: String, error: (any Error)?) async
    func scheduleCaptures(logLevel: LogLevel, message: String, error: (any Error)?) async
    func stopCaptures() async
}

actor DefaultLogSchedulerService: LogSchedulerService {
    private var task: Task<Void, Never>?

    func capture(
        logLevel: LogLevel,
        message: String,
        error: (any Error)?
    ) {
        switch logLevel {
        case .debug: Logger.other.debug(message, error: error)
        case .info: Logger.other.info(message, error: error)
        case .error: Logger.other.error(message, error: error)
        case .critical: Logger.other.critical(message, error: error)
        default:
            preconditionFailure("Unsupported log level: \(logLevel)")
        }
    }

    func scheduleCaptures(
        logLevel: LogLevel,
        message: String,
        error: (any Error)?
    ) {
        // cancel any the previous schedule
        stopCaptures()

        task = Task {
            do {
                // Trigger a log every second.
                for await _ in Timer.publish(every: 1, on: .main, in: .common).autoconnect().values {
                    try Task.checkCancellation()
                    capture(
                        logLevel: logLevel,
                        message: "[\(Date())] trigger loop: \(message)",
                        error: error
                    )
                }
            } catch {
                Logger.app.info("Scheduled captures stopped due to error", error: error)
            }
        }
    }

    func stopCaptures() {
        Logger.app.info("Stopping captures")
        task?.cancel()
    }
}

actor MockLogSchedulerService: LogSchedulerService {
    func capture(logLevel: LogLevel, message: String, error: (any Error)?) async {}
    func scheduleCaptures(logLevel: LogLevel, message: String, error: (any Error)?) async {}
    func stopCaptures() async {}
}

extension EnvironmentValues {
    @Entry var logSchedulerService: any LogSchedulerService = DefaultLogSchedulerService()
}

extension View {
    func logSchedulerService(_ logSchedulerService: any LogSchedulerService) -> some View {
        environment(\.logSchedulerService, logSchedulerService)
    }
}
