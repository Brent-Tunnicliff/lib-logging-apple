// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Algorithms
import Foundation
import SwiftData
import Testing

@testable import LoggingCore

struct LoggingServiceTests {
    private let loggingService: DefaultLoggingService
    private let mockDeviceProvider = MockDeviceProvider()
    private let mockFileService = MockFileService()
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
            fileService: mockFileService,
            logCleanupTrigger: mockLogCleanupTrigger,
            modelContainer: modelContainer,
            modelMapper: mockModelMapper,
            userDefaults: mockUserDefaultsStore
        )
        self.registerForCleanupStream = registerForCleanupStream
    }

    // MARK: - deleteLogs(olderThan:)

    @Test
    func deleteLogs() async throws {
        // data setup
        let olderThanDate = Date()
        let logsToDelete = [
            Date(timeInterval: -10, since: olderThanDate),
            Date(timeInterval: -20, since: olderThanDate),
            Date(timeInterval: -30, since: olderThanDate),
            Date(timeInterval: -40, since: olderThanDate),
            Date(timeInterval: -50, since: olderThanDate),
        ].map { LogEntity.mock(timestampCreated: $0) }

        let logsToKeep = [
            Date(timeInterval: 10, since: olderThanDate),
            Date(timeInterval: 20, since: olderThanDate),
            Date(timeInterval: 30, since: olderThanDate),
            Date(timeInterval: 40, since: olderThanDate),
            Date(timeInterval: 50, since: olderThanDate),
            Date(timeInterval: 60, since: olderThanDate),
        ].map { LogEntity.mock(timestampCreated: $0) }

        let modelContext = ModelContext(modelContainer)
        modelContext.autosaveEnabled = false
        try modelContext.transaction {
            for log in logsToDelete + logsToKeep {
                modelContext.insert(log)
            }

            try modelContext.save()
        }

        // test
        try await loggingService.deleteLogs(olderThan: olderThanDate)

        // verify
        let results: [LogEntity] = try modelContext.fetch(FetchDescriptor())
        #expect(results.count == logsToKeep.count)
        for expectedResult in logsToKeep {
            let result = results.first { $0.id == expectedResult.id }
            #expect(
                result != nil,
                "Missing expected result: \(expectedResult.timestampCreated), olderThanDate: \(olderThanDate)"
            )
        }
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
    }

    @Test
    func storeLogLowerThanDefinedLogLevelIsIgnored() async throws {
        mockUserDefaultsStore.minimalLogLevel = .info
        try await performStoreLog(logLevel: .debug)
        let result: [LogEntity] = try ModelContext(modelContainer).fetch(FetchDescriptor())
        #expect(result.isEmpty)
    }

    @Test
    func storeLogEqualToDefinedLogLevelIsStored() async throws {
        mockUserDefaultsStore.minimalLogLevel = .info
        try await performStoreLog(logLevel: .info)
        let result: [LogEntity] = try ModelContext(modelContainer).fetch(FetchDescriptor())
        #expect(!result.isEmpty)
    }

    // MARK: - registerForCleanup()

    @Test(.timeLimit(.minutes(1)))
    func registerForCleanup() async throws {
        let now = Date()
        let logToDelete = LogEntity.mock(
            timestampCreated: Date(timeInterval: -TimeInterval(duration: .days(91)), since: now)
        )

        let logToKeep = LogEntity.mock(
            timestampCreated: Date(timeInterval: -TimeInterval(duration: .days(89)), since: now)
        )

        let modelContext = ModelContext(modelContainer)
        modelContext.autosaveEnabled = false
        try modelContext.transaction {
            modelContext.insert(logToDelete)
            modelContext.insert(logToKeep)

            try modelContext.save()
        }

        async let storeLogCleanupCalled = withCheckedContinuation { continuation in
            mockLogCleanupTrigger.storeLogCleanupResponse = { _ in
                continuation.resume(returning: true)
            }
        }

        try await registerForCleanupStream.waitForContinuation()
        registerForCleanupStream.continuation.yield()

        await #expect(storeLogCleanupCalled == true)

        let results: [LogEntity] = try modelContext.fetch(FetchDescriptor())
        #expect(results.count == 1)
        #expect(results.first?.id == logToKeep.id)

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
            timestamp: timestamp
        )

        // Manually save as we don't want to wait until the autosave every 60 seconds.
        try await loggingService.save()
    }
}
