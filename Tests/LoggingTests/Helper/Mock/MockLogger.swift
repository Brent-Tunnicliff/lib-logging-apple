// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

@testable import Logging

@MainActor
final class MockLogger: LoggerType {
    var logCompletionHandler: @Sendable () -> Void = {}
    var logCalled: Bool { !logInputs.isEmpty }
    typealias LogInputsType = (
        level: LogLevel,
        message: String,
        tag: Logging.LogTag,
        error: (any Error)?
    )
    private(set) var logInputs: [LogInputsType] = []
    nonisolated func log(
        level: LogLevel,
        _ message: String,
        tag: Logging.LogTag,
        error: (any Error)?
    ) {
        Task { @MainActor in
            defer {
                logCompletionHandler()
            }

            logInputs.append((level, message, tag, error))
        }
    }
}
