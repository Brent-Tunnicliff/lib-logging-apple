// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import LoggingCore
import Testing

@testable import Logging

/// Tests for Logger extension functions.
struct LoggerTests {
    private let logger = MockLogger()
    private let message = "This message should be sent to the places"
    private let file: StaticString = "1"
    private let function: StaticString = "2"
    private let line: UInt = 3
    private let error = MockError()

    @Test
    func debug() async {
        await testLog(expectedLogLevel: .debug) {
            logger.debug(message, error: error, file: file, function: function, line: line)
        }
    }

    @Test
    func info() async {
        await testLog(expectedLogLevel: .info) {
            logger.info(message, error: error, file: file, function: function, line: line)
        }
    }

    @Test
    func error() async {
        await testLog(expectedLogLevel: .error) {
            logger.error(message, error: error, file: file, function: function, line: line)
        }
    }

    @Test
    func critical() async {
        await testLog(expectedLogLevel: .critical) {
            logger.critical(message, error: error, file: file, function: function, line: line)
        }
    }

    private func testLog(
        expectedLogLevel: LogLevel,
        sourceLocation: Testing.SourceLocation = #_sourceLocation,
        action: @escaping @Sendable () -> Void
    ) async {
        let logInputs = await AsyncStream { continuation in
            Task { @MainActor in
                logger.logResponse = {
                    // In the the real logger we don't care if we jump isolation.
                    // But this test is built with the assumption we never jump isolations.
                    // So assert we are still on the Main actor to avoid unreliable results.
                    MainActor.assertIsolated()
                    continuation.yield($0)
                }

                action()
                continuation.finish()
            }
        }
        .reduce(into: [MockLogger.LogInput]()) { partialResult, logInput in
            partialResult.append(logInput)
        }

        #expect(logInputs.count == 1, sourceLocation: sourceLocation)
        guard let result = logInputs.first else {
            Issue.record("Unexpected nil result", sourceLocation: sourceLocation)
            return
        }

        let expectedTag = LogTag(file: file, function: function, line: line)

        #expect(result.level == expectedLogLevel, sourceLocation: sourceLocation)
        #expect(result.message == message, sourceLocation: sourceLocation)
        #expect(result.tag == expectedTag, sourceLocation: sourceLocation)

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
