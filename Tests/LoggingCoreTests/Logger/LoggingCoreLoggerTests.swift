// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Synchronization
import Testing
@testable import LoggingCore

struct LoggingCoreLoggerTests {
    private let expectedMessage = "LoggingCoreLoggerTests message"
    private let expectedError = MockError()
    private let expectedFile: StaticString = "Logging/LogEntity.swift"
    private let expectedFunction: StaticString = "mock(file:function:line:)"
    private let expectedLine: UInt = 75
    private let mockLoggingCoreLogger = MockLoggingCoreLogger()

    @Test
    func critical() throws {
        mockLoggingCoreLogger.critical(
            expectedMessage,
            error: expectedError,
            file: expectedFile,
            function: expectedFunction,
            line: expectedLine
        )

        try expectLogged(with: .critical)
    }

    @Test
    func debug() throws {
        mockLoggingCoreLogger.debug(
            expectedMessage,
            error: expectedError,
            file: expectedFile,
            function: expectedFunction,
            line: expectedLine
        )

        try expectLogged(with: .debug)
    }

    @Test
    func error() throws {
        mockLoggingCoreLogger.error(
            expectedMessage,
            error: expectedError,
            file: expectedFile,
            function: expectedFunction,
            line: expectedLine
        )

        try expectLogged(with: .error)
    }

    @Test
    func info() throws {
        mockLoggingCoreLogger.info(
            expectedMessage,
            error: expectedError,
            file: expectedFile,
            function: expectedFunction,
            line: expectedLine
        )

        try expectLogged(with: .info)
    }

    private func expectLogged(
        with level: LogLevel,
        fileID: String = #fileID,
        filePath: String = #filePath,
        line: Int = #line,
        column: Int = #column
    ) throws {
        let sourceLocation = SourceLocation(
            fileID: fileID,
            filePath: filePath,
            line: line,
            column: column
        )
        let result = try #require(mockLoggingCoreLogger.logInputs.withLock { $0 }, sourceLocation: sourceLocation)
        #expect(result.level == level, sourceLocation: sourceLocation)
        #expect(result.message == expectedMessage, sourceLocation: sourceLocation)
        #expect(result.tag.file.description == expectedFile.description, sourceLocation: sourceLocation)
        #expect(result.tag.function.description == expectedFunction.description, sourceLocation: sourceLocation)
        #expect(result.tag.line == expectedLine, sourceLocation: sourceLocation)
        #expect(result.error == expectedError, sourceLocation: sourceLocation)
    }
}

private final class MockLoggingCoreLogger: LoggingCoreLogger {
    let logInputs = Mutex<(level: LogLevel, message: String, tag: LogTag, error: (any Error)?)?>(nil)
    func log(
        level: LogLevel,
        message: String,
        tag: LogTag,
        error: (any Error)?
    ) {
        logInputs.withLock {
            $0 = (level, message, tag, error)
        }
    }
}
