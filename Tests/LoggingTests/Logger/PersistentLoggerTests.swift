// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation
import Testing

@testable import Logging

struct PersistentLoggerTests {
    private let message = "This message should be sent to the places"
    private let packageName = "LoggingTests"
    private let mockLoggingService: MockLoggingService
    private let mockSystemLogger = MockLogger()
    private let logger: PersistentLogger

    init() async {
        let mockLoggingService = await MockLoggingService()
        self.mockLoggingService = mockLoggingService
        self.logger = PersistentLogger(
            loggingService: Task { mockLoggingService },
            packageName: packageName,
            systemLogger: mockSystemLogger
        )
    }

    @Test(arguments: product(LogLevel.allCases, [true, false]))
    func logSendsExpectedDataToSystemLog(level: LogLevel, sendError: Bool) async {
        let tag = LogTag(file: #file, function: #function, line: #line)
        let error = sendError ? MockError() : nil

        logger.log(level: level, message, tag: tag, error: error)

        let logInputs = await mockSystemLogger.logInputs
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

        await withCheckedContinuation { continuation in
            Task {
                await mockLoggingService.inject(storeLogCompletionHandler: {
                    continuation.resume()
                })

                logger.log(level: level, message, tag: tag, error: error)
            }
        }

        let after = Date()
        let storeLogInput = await mockLoggingService.storeLogInput
        #expect(storeLogInput.count == 1)
        guard let result = storeLogInput.first else {
            Issue.record("Unexpected nil result")
            return
        }

        #expect(result.logLevel == level)
        #expect(result.message == message)
        #expect(result.packageName == packageName)
        #expect(result.tag == tag)
        #expect(result.timestamp >= before)
        #expect(result.timestamp <= after)
        expectError(resultError: result.error, expectedError: error)
    }

    @Test(.timeLimit(.minutes(1)))
    func logCapturesThrownErrorInSystemLog() async {
        let thrownError = MockError()
        await mockLoggingService.inject(storeLogThrow: thrownError)

        await withCheckedContinuation { continuation in
            Task { @MainActor in
                var completed = false
                mockSystemLogger.logCompletionHandler = {
                    Task { @MainActor in
                        if completed == false, mockSystemLogger.logInputs.count == 2 {
                            continuation.resume()
                            completed = true
                        }
                    }
                }

                logger.log(
                    level: .debug,
                    message,
                    tag: LogTag(file: #file, function: #function, line: #line),
                    error: nil
                )
            }
        }

        let logInputs = await mockSystemLogger.logInputs
        #expect(logInputs.count == 2)
        guard let result = logInputs.last else {
            Issue.record("Unexpected nil result")
            return
        }

        #expect(result.level == .critical)
        #expect(result.message == "Storing log failed: MockError()")
        expectError(resultError: result.error, expectedError: thrownError)
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
