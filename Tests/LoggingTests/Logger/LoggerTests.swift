// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Testing

@testable import Logging

/// Tests for Logger extension functions.
@MainActor
struct LoggerTests {
    private let logger = MockLogger()
    private let message = "This message should be sent to the places"
    private let tag = LogTag()
    private let error = MockError()

    @Test
    func debug() async {
        await testLog(expectedLogLevel: .debug) {
            logger.debug(message, tag: tag, error: error)
        }
    }

    @Test
    func info() async {
        await testLog(expectedLogLevel: .info) {
            logger.info(message, tag: tag, error: error)
        }
    }

    @Test
    func error() async {
        await testLog(expectedLogLevel: .error) {
            logger.error(message, tag: tag, error: error)
        }
    }

    @Test
    func critical() async {
        await testLog(expectedLogLevel: .critical) {
            logger.critical(message, tag: tag, error: error)
        }
    }

    private func testLog(
        expectedLogLevel: LogLevel,
        sourceLocation: Testing.SourceLocation = #_sourceLocation,
        action: () -> Void
    ) async {
        await withCheckedContinuation { continuation in
            Task { @MainActor in
                logger.logCompletionHandler = {
                    continuation.resume()
                }
            }

            action()
        }

        let logInputs = logger.logInputs
        #expect(logInputs.count == 1, sourceLocation: sourceLocation)
        guard let result = logInputs.first else {
            Issue.record("Unexpected nil result", sourceLocation: sourceLocation)
            return
        }

        #expect(result.level == expectedLogLevel, sourceLocation: sourceLocation)
        #expect(result.message == message, sourceLocation: sourceLocation)
        #expect(result.tag == tag, sourceLocation: sourceLocation)

        guard let resultError = result.error else {
            Issue.record("result error nil", sourceLocation: sourceLocation)
            return
        }

        guard let errorResult = resultError as? MockError else {
            Issue.record(
                "result error: '\(resultError)', expected error: 'MockError'",
                sourceLocation: sourceLocation
            )
            return
        }

        #expect(errorResult == error, sourceLocation: sourceLocation)
    }
}
