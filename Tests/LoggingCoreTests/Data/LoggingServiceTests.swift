// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Algorithms
import Foundation
import SwiftData
import Testing

@testable import LoggingCore

struct LoggingServiceTests {
    private let loggingService: DefaultLoggingService
    private let mockDeviceProvider = MockDeviceProvider()
    private let mockFileManager = MockFileManager()
    private let mockLogCleanupTrigger = MockLogCleanupTrigger()
    private let mockModelMapper = MockModelMapper()
    private let modelContainer: ModelContainer
    private let mockUserDefaultsStore = MockUserDefaultsStore()
    private let registerForCleanupStream: MockAsyncStream<Void>

    private let message = "This message should be sent to the places"
    private let packageName = "LoggingTests"
    private let tag = LogTag(
        file: "file",
        function: "function",
        line: 1
    )
    private let timestamp = Date()
    private let thread = "Main"
    private let expectedSupportedLogLevels: [LogLevel: [LogLevel]] = [
        .debug: LogLevel.allCases,
        .info: [.info, .error, .critical],
        .error: [.error, .critical],
        .critical: [.critical],
    ]

    // Isolating the init to `@MainActor` to avoid a potential crash
    // when calling `ModelContainer.emptyInMemoryOnly()` concurrently.
    @MainActor
    init() async throws {
        let registerForCleanupStream = MockAsyncStream<Void>()
        self.mockLogCleanupTrigger.registerForCleanupResponse = {
            registerForCleanupStream
        }
        self.modelContainer = .emptyInMemoryOnly()
        self.loggingService = DefaultLoggingService(
            deviceProvider: mockDeviceProvider,
            fileManager: mockFileManager,
            logCleanupTrigger: mockLogCleanupTrigger,
            modelContainer: modelContainer,
            modelMapper: mockModelMapper,
            userDefaults: mockUserDefaultsStore
        )
        self.registerForCleanupStream = registerForCleanupStream
    }

    // MARK: - storeLog(error:logLevel:message:packageName:tag:timestamp:)

    @Test(arguments: Array(product(LogLevel.allCases, [true, false])))
    func storeLog(level: LogLevel, sendError: Bool) async throws {
        let error = sendError ? MockError() : nil
        let expectedDevice = LogEntity.Device.mock()
        let expectedError = sendError ? LogEntity.Error.mock() : nil
        let expectedLogLevel = LogEntity.LogLevel.info
        let expectedTag = LogEntity.Tag.mock()

        // We need to pass in the mock results on init so it stays Sendable.
        // So creating new mapper and service here.
        mockModelMapper.toEntityDeviceResponse = { _ in expectedDevice }
        mockModelMapper.toEntityErrorResponse = { _ in expectedError ?? .mock() }
        mockModelMapper.toEntityLogLevelResponse = { _ in expectedLogLevel }
        mockModelMapper.toEntityLogTagResponse = { _ in expectedTag }
        mockModelMapper.toEntityUserInterfaceIdiomResponse = { _ in expectedDevice.userInterfaceIdiom }

        mockUserDefaultsStore.minimalLogLevel = level
        try await performStoreLog(error: error, logLevel: level)
        let results: [LogEntity] = try ModelContext(modelContainer).fetch(FetchDescriptor())
        #expect(results.count == 1)

        guard let result = results.first else {
            Issue.record("Unexpected nil result")
            return
        }

        #expect(result.device == expectedDevice)
        #expect(result.level == expectedLogLevel)
        #expect(result.message == message)
        #expect(result.packageName == packageName)
        #expect(result.tag == expectedTag)
        #expect(result.timestampCreated == timestamp)
        #expect(result.error == expectedError)
        #expect(result.thread == thread)
    }

    @Test(arguments: LogLevel.allCases)
    func storeLogFilterLogsBelowMinimumLevel(minimalLogLevel: LogLevel) async throws {
        guard let expectedCount = expectedSupportedLogLevels[minimalLogLevel]?.count else {
            Issue.record("'\(minimalLogLevel)' has no supported LogLevels")
            return
        }

        mockUserDefaultsStore.minimalLogLevel = minimalLogLevel
        for logLevel in LogLevel.allCases {
            try await performStoreLog(logLevel: logLevel)
        }

        let result: [LogEntity] = try ModelContext(modelContainer).fetch(FetchDescriptor())
        #expect(result.count == expectedCount)
    }

    // MARK: - registerForCleanup()

    @Test(.timeLimit(.minutes(1)))
    func registerForCleanup() async throws {
        // data setup
        let expectedLogRetentionDays = 90
        let now = Date()

        // We don't care too much about precision, testing that logs from 91 days old is good enough.
        // Otherwise we might introduce flaky tests.
        let logsToDelete = (1...100).map {
            LogEntity.mock(
                timestampCreated: Date(
                    timeInterval: -TimeInterval(
                        duration: .days(expectedLogRetentionDays + $0)
                    ),
                    since: now
                )
            )
        }

        let logsToKeep = (0..<expectedLogRetentionDays).map {
            LogEntity.mock(
                timestampCreated: Date(timeInterval: -TimeInterval(duration: .days($0)), since: now)
            )
        }

        let allLogs = logsToDelete + logsToKeep
        let modelContext = ModelContext(modelContainer)
        modelContext.autosaveEnabled = false
        try modelContext.transaction {
            for log in allLogs {
                modelContext.insert(log)
            }

            try modelContext.save()
        }

        // lets just double check that there are the expected number of logs created in setup
        // as the rest of the test expects this data.
        let validateDataResult: [LogEntity] = try! modelContext.fetch(FetchDescriptor())
        let expectedValidateDataResultCount = 190
        guard validateDataResult.count == expectedValidateDataResultCount else {
            Issue.record(
                "Test setup expected \(expectedValidateDataResultCount) entities but got \(validateDataResult.count)"
            )
            return
        }

        async let storeLogCleanupCalled = withCheckedContinuation { continuation in
            mockLogCleanupTrigger.storeLogCleanupResponse = { _ in
                continuation.resume(returning: true)
            }
        }

        try await registerForCleanupStream.waitForContinuation()

        // test
        registerForCleanupStream.continuation.yield()
        await #expect(storeLogCleanupCalled == true)

        // verify
        let results: [LogEntity] = try modelContext.fetch(FetchDescriptor())
        #expect(results.count == logsToKeep.count)
        for expectedResult in logsToKeep {
            let result = results.first { $0.id == expectedResult.id }
            #expect(
                result != nil,
                "Missing expected result: \(expectedResult.timestampCreated), olderThanDate: \(now)"
            )
        }
    }

    // MARK: - Helpers

    private func performStoreLog(
        error: (any Error)? = nil,
        logLevel: LogLevel
    ) async throws {
        await loggingService.storeLog(
            error: error,
            logLevel: logLevel,
            message: message,
            packageName: packageName,
            tag: tag,
            timestamp: timestamp,
            thread: thread
        )

        // Manually save as we don't want to wait until the autosave every 60 seconds.
        try await loggingService.save()
    }
}
