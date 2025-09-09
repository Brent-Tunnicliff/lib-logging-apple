// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation
import Logging
import SwiftUI

protocol LogSchedulerService: Sendable {
    func capture(logLevel: LogLevel, message: String, error: (any Error)?)
    func scheduleCaptures(every seconds: TimeInterval, logLevel: LogLevel, message: String, error: (any Error)?) -> UUID
    func cancelCaptures(id: UUID)
}

actor DefaultLogSchedulerService: LogSchedulerService {
    static let shared = DefaultLogSchedulerService()

    private var tasks: [UUID: Task<Void, Never>] = [:]

    nonisolated func capture(
        logLevel: LogLevel,
        message: String,
        error: (any Error)?
    ) {
        switch logLevel {
        case .debug: Logger.other.debug(message, error: error)
        case .info: Logger.other.info(message, error: error)
        case .error: Logger.other.error(message, error: error)
        case .critical: Logger.other.critical(message, error: error)
        }
    }

    nonisolated func scheduleCaptures(
        every seconds: TimeInterval,
        logLevel: LogLevel,
        message: String,
        error: (any Error)?
    ) -> UUID {
        let id = UUID()
        let task = Task.detached { [weak self] in
            do {
                // Trigger a log every second.
                for await _ in Timer.publish(every: seconds, on: .main, in: .common).autoconnect().values {
                    try Task.checkCancellation()
                    self?.capture(
                        logLevel: logLevel,
                        message: "[\(Date())] trigger loop: \(message)",
                        error: error
                    )
                }
            } catch {
                Logger.app.info("Scheduled captures stopped due to error", error: error)
            }
        }

        Task.detached { [weak self] in
            await self?.store(task: task, id: id)
        }

        return id
    }

    nonisolated func cancelCaptures(id: UUID) {
        Task.detached { [weak self] in
            await self?.cancel(id: id)
        }
    }

    private func cancel(id: UUID) {
        tasks[id]?.cancel()
        tasks[id] = nil
    }

    private func store(task: Task<Void, Never>, id: UUID) {
        // In the very unlikely chance of id already being in use, lets just cancel the old one.
        tasks[id]?.cancel()
        tasks[id] = task
    }
}

final class MockLogSchedulerService: LogSchedulerService {
    func capture(logLevel: LogLevel, message: String, error: (any Error)?) {}

    func scheduleCaptures(
        every seconds: TimeInterval,
        logLevel: LogLevel,
        message: String,
        error: (any Error)?
    ) -> UUID {
        UUID()
    }

    func cancelCaptures(id: UUID) {}
}

extension EnvironmentValues {
    @Entry var logSchedulerService: any LogSchedulerService = DefaultLogSchedulerService.shared
}

extension View {
    func logSchedulerService(_ logSchedulerService: any LogSchedulerService) -> some View {
        environment(\.logSchedulerService, logSchedulerService)
    }
}
