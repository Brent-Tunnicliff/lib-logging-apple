// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation
import LoggingCore
import Testing

@testable import Logging

struct DefaultLoggerTests {
    private let message = "This message should be sent to the places"
    private let packageName = "LoggingTests"
    private let mockLoggingService = MockLoggingService()
    private let mockSystemLogger = MockLogger()
    private let logger: DefaultLogger

    init() {
        self.logger = DefaultLogger(
            loggingService: mockLoggingService,
            packageName: packageName,
            systemLogger: mockSystemLogger
        )
    }

    // MARK: - Tests

    @Test(arguments: product(LogLevel.allCases, [true, false]))
    func logSendsExpectedDataToSystemLog(level: LogLevel, sendError: Bool) async {
        let tag = LogTag(file: #file, function: #function, line: #line)
        let error = sendError ? MockError() : nil

        let logInputs = await AsyncStream { continuation in
            mockSystemLogger.logResponse = { input in
                continuation.yield(input)
            }
            logger.log(level: level, message, tag: tag, error: error)
            continuation.finish()
        }.reduce(into: [MockLogger.LogInput]()) { partialResult, input in
            partialResult.append(input)
        }

        #expect(logInputs.count == 1)
        guard let result = logInputs.first else {
            Issue.record("Unexpected nil result")
            return
        }

        #expect(result.level == level)
        #expect(result.message == message)
        #expect(result.tag == tag)
        expectError(resultError: result.error, expectedError: error)
    }

    @Test(arguments: product(LogLevel.allCases, [true, false]))
    func logSendsExpectedDataToLoggingService(level: LogLevel, sendError: Bool) async {
        let before = Date()
        let tag = LogTag(file: #file, function: #function, line: #line)
        let error = sendError ? MockError() : nil

        let result = await withCheckedContinuation { continuation in
            mockLoggingService.storeLogResponse = {
                continuation.resume(returning: $0)
            }

            logger.log(level: level, message, tag: tag, error: error)
        }

        let after = Date()
        #expect(result.logLevel == level)
        #expect(result.message == message)
        #expect(result.packageName == packageName)
        #expect(result.tag == tag)
        #expect(result.timestamp >= before)
        #expect(result.timestamp <= after)
        expectError(resultError: result.error, expectedError: error)
    }

    private func expectError<ResultError: Error, ExpectedError: Error & Equatable>(
        resultError: ResultError?,
        expectedError: ExpectedError?,
        sourceLocation: Testing.SourceLocation = #_sourceLocation
    ) {
        guard let expectedError else {
            #expect(resultError == nil, sourceLocation: sourceLocation)
            return
        }

        guard let resultError else {
            Issue.record(
                "result error nil, expected error: '\(expectedError)'",
                sourceLocation: sourceLocation
            )
            return
        }

        guard let errorResult = resultError as? ExpectedError else {
            Issue.record(
                "result error: '\(resultError)', expected error: '\(expectedError)'",
                sourceLocation: sourceLocation
            )
            return
        }

        #expect(errorResult == expectedError, sourceLocation: sourceLocation)
    }
}
