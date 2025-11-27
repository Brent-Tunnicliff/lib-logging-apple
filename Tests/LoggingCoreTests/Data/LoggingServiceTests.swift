// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Algorithms
import Foundation
import SwiftData
import Synchronization
import Testing

@testable import LoggingCore

struct LoggingServiceTests {
    private let loggingService: DefaultLoggingService
    private let mockDateProvider = MockDateProvider()
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
            dateProvider: mockDateProvider,
            deviceProvider: mockDeviceProvider,
            exportBufferingPolicy: .unbounded,
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

    // This test has issues with flakiness in ci that I cannot reproduce locally.
    // I made optimisations with the test to reduce risks of race conditions, but still seeing the issue.
    // Test usually takes several seconds to complete, but sometimes the iOS ci job will timeout at 1 minute.
    @Test(.timeLimit(.minutes(1)))
    func registerForCleanup() async throws {
        print("registerForCleanup start")
        let storeLogCleanupCalled = AsyncThrowingStream<Void, any Error>.makeStream()
        mockLogCleanupTrigger.storeLogCleanupResponse = { _ in
            storeLogCleanupCalled.continuation.finish()
        }

        // Not ideal to observe internal logic, but we need to wait until the Task is ready, else the test hangs.
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, any Error>) in
            let timer = Task { @MainActor in
                try await Task.sleep(for: .seconds(2))
                continuation.resume(throwing: TestError.timeout("isCleanupTaskReady"))
            }

            Task { @MainActor in
                while !timer.isCancelled {
                    if await loggingService.isCleanupTaskReady {
                        timer.cancel()
                        continuation.resume()
                    }

                    try await Task.sleep(for: .milliseconds(10))
                }
            }
        }

        // data setup
        print("registerForCleanup data setup")
        let modelContext = ModelContext(modelContainer)
        let expectedLogRetentionDays = 90
        let now = mockDateProvider.now

        // We don't care too much about precision, testing that logs from 91 days old is good enough.
        // Otherwise we might introduce flaky tests.
        let logsToDelete = (1...100).map {
            LogEntity.mock(
                timestampCreated: mockDateProvider.now(
                    subtracting: Duration.days(expectedLogRetentionDays + $0).asTimeInterval
                )
            )
        }

        let logsToKeep = (0..<expectedLogRetentionDays).map {
            LogEntity.mock(
                timestampCreated: mockDateProvider.now(adding: Duration.days($0).asTimeInterval)
            )
        }

        print("registerForCleanup inserting logs")
        let allLogs = logsToDelete + logsToKeep
        for log in allLogs {
            modelContext.insert(log)
        }

        try modelContext.save()

        print("registerForCleanup logs saved")

        // lets just double check that there are the expected number of logs created in setup
        // as the rest of the test expects this data.
        let validateDataResult: [LogEntity] = try modelContext.fetch(FetchDescriptor())
        let expectedValidateDataResultCount = 190
        guard validateDataResult.count == expectedValidateDataResultCount else {
            Issue.record(
                "Test setup expected \(expectedValidateDataResultCount) entities but got \(validateDataResult.count)"
            )
            return
        }

        // Maybe this will help with the flaky test? :(
        try await Task.sleep(for: .seconds(2))

        print("registerForCleanup starting test")

        // ready to perform the real test
        registerForCleanupStream.continuation.yield()

        for try await _ in storeLogCleanupCalled.stream {
            // Won't return any values, we just want it to finish with success or failure.
        }

        // verify
        print("registerForCleanup verify results")
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

    // MARK: - exportLogs()

    @Test
    func exportLogs() async throws {
        let modelContext = ModelContext(modelContainer)
        _ = try await runExportTestSetup(
            loggingService: loggingService,
            modelContext: modelContext
        ).url.value

        let expectedResult = expectedExportResult()
        let result = mockFileManager.mockWritableFileHandleType.writeInput.joined()
        #expect(result == expectedResult)
        #expect(mockFileManager.mockWritableFileHandleType.synchronizeCalled)
    }

    @Test(.timeLimit(.minutes(1)))
    func exportLogsProgress() async throws {
        let modelContext = ModelContext(modelContainer)
        let progress = try await runExportTestSetup(
            loggingService: loggingService,
            modelContext: modelContext
        ).progress

        let expectedResults = [0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 0.875, 1.0]
        var progressValues: [Double] = []
        for await value in progress {
            progressValues.append(value)
        }

        #expect(progressValues == expectedResults)
    }

    /// Uses a real database and FileManager so we make sure it works.
    @Test
    func exportLogsIntegrationTest() async throws {
        let container = try await Task { @MainActor in
            try ModelContainer(
                for: Schema(versionedSchema: LatestSchema.self),
                configurations: ModelConfiguration("exportLogsIntegrationTest_\(UUID().uuidString)")
            )
        }.value

        // We want to use the real file manage for the integration test.
        let realFileManager = DefaultFileManager()
        let modelContext = ModelContext(container)
        let urlResult = try await runExportTestSetup(
            loggingService: DefaultLoggingService(
                dateProvider: mockDateProvider,
                deviceProvider: mockDeviceProvider,
                exportBufferingPolicy: .unbounded,
                fileManager: realFileManager,
                logCleanupTrigger: mockLogCleanupTrigger,
                modelContainer: container,
                modelMapper: mockModelMapper,
                userDefaults: mockUserDefaultsStore
            ),
            modelContext: modelContext
        ).url.value

        // Cleanup file when not needed.
        defer {
            do {
                try FileManager.default.removeItem(at: urlResult)
            } catch {
                Issue.record(error, "Failed to clean up file \(urlResult.absoluteString)")
            }
        }

        #expect(FileManager.default.fileExists(atPath: urlResult.path()))

        guard let resultData = FileManager.default.contents(atPath: urlResult.path()) else {
            Issue.record("Unable to get contents of file \(urlResult.absoluteString)")
            return
        }

        guard let result = String(data: resultData, encoding: .utf8) else {
            Issue.record("Unable to decode contents of file \(urlResult.absoluteString)")
            return
        }

        let expectedResult = expectedExportResult()
        #expect(result == expectedResult)
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

    private func runExportTestSetup(
        loggingService: any LoggingService,
        modelContext: ModelContext
    ) async throws -> (progress: AsyncStream<Double>, url: Task<URL, any Error>) {
        // Setup
        let realModelMapper = DefaultModelMapper()
        // We actually want the real export for this test.
        mockModelMapper.toExportContentLogEntityResponse = realModelMapper.toExportContent(logEntity:)

        let device = LogEntity.Device.mock(
            identifierForVendor: .forced(uuidString: "BD0ED1A2-8CA2-4384-8211-A1655A5E2FC9")
        )

        let logs: [LogEntity] = [
            .mock(
                device: device,
                id: .forced(uuidString: "00000000-0000-0000-0000-000000000001"),
                level: .debug,
                timestampCreated: mockDateProvider.now(subtracting: 1),
                error: nil,
                thread: "Main"
            ),
            .mock(
                device: device,
                id: .forced(uuidString: "00000000-0000-0000-0000-000000000002"),
                level: .info,
                timestampCreated: mockDateProvider.now(subtracting: 2),
                error: nil,
                thread: "0002"
            ),
            .mock(
                device: device,
                id: .forced(uuidString: "00000000-0000-0000-0000-000000000003"),
                level: .error,
                timestampCreated: mockDateProvider.now(subtracting: 3),
                error: nil,
                thread: "0003"
            ),
            .mock(
                device: device,
                id: .forced(uuidString: "00000000-0000-0000-0000-000000000004"),
                level: .critical,
                timestampCreated: mockDateProvider.now(subtracting: 4),
                error: nil,
                thread: "0004"
            ),
            .mock(
                device: device,
                id: .forced(uuidString: "00000000-0000-0000-0000-000000000005"),
                level: .debug,
                timestampCreated: mockDateProvider.now(subtracting: 5),
                error: .mock(),
                thread: "0005"
            ),
            .mock(
                device: device,
                id: .forced(uuidString: "00000000-0000-0000-0000-000000000006"),
                level: .info,
                timestampCreated: mockDateProvider.now(subtracting: 6),
                error: .mock(),
                thread: "0006"
            ),
            .mock(
                device: device,
                id: .forced(uuidString: "00000000-0000-0000-0000-000000000007"),
                level: .error,
                timestampCreated: mockDateProvider.now(subtracting: 7),
                error: .mock(),
                thread: "0007"
            ),
            .mock(
                device: device,
                id: .forced(uuidString: "00000000-0000-0000-0000-000000000008"),
                level: .critical,
                timestampCreated: mockDateProvider.now(subtracting: 8),
                error: .mock(),
                thread: "0008"
            ),
        ]

        try modelContext.transaction {
            for log in logs {
                modelContext.insert(log)
            }
        }

        return try await loggingService.exportLogs()
    }

    private func expectedExportResult() -> String {
        """
        2024-12-31T23:59:52Z [0008] [Logging] [critical] [Logging/LogEntity.swift:mock(file:function:line:):76] Mock log, error: Mock - Something went wrong (not really) (Something went wrong in locale), device: BD0ED1A2-8CA2-4384-8211-A1655A5E2FC9 iPhone iOS 18.3 (phone)
        2024-12-31T23:59:53Z [0007] [Logging] [error   ] [Logging/LogEntity.swift:mock(file:function:line:):76] Mock log, error: Mock - Something went wrong (not really) (Something went wrong in locale), device: BD0ED1A2-8CA2-4384-8211-A1655A5E2FC9 iPhone iOS 18.3 (phone)
        2024-12-31T23:59:54Z [0006] [Logging] [info    ] [Logging/LogEntity.swift:mock(file:function:line:):76] Mock log, error: Mock - Something went wrong (not really) (Something went wrong in locale), device: BD0ED1A2-8CA2-4384-8211-A1655A5E2FC9 iPhone iOS 18.3 (phone)
        2024-12-31T23:59:55Z [0005] [Logging] [debug   ] [Logging/LogEntity.swift:mock(file:function:line:):76] Mock log, error: Mock - Something went wrong (not really) (Something went wrong in locale), device: BD0ED1A2-8CA2-4384-8211-A1655A5E2FC9 iPhone iOS 18.3 (phone)
        2024-12-31T23:59:56Z [0004] [Logging] [critical] [Logging/LogEntity.swift:mock(file:function:line:):76] Mock log, device: BD0ED1A2-8CA2-4384-8211-A1655A5E2FC9 iPhone iOS 18.3 (phone)
        2024-12-31T23:59:57Z [0003] [Logging] [error   ] [Logging/LogEntity.swift:mock(file:function:line:):76] Mock log, device: BD0ED1A2-8CA2-4384-8211-A1655A5E2FC9 iPhone iOS 18.3 (phone)
        2024-12-31T23:59:58Z [0002] [Logging] [info    ] [Logging/LogEntity.swift:mock(file:function:line:):76] Mock log, device: BD0ED1A2-8CA2-4384-8211-A1655A5E2FC9 iPhone iOS 18.3 (phone)
        2024-12-31T23:59:59Z [Main] [Logging] [debug   ] [Logging/LogEntity.swift:mock(file:function:line:):76] Mock log, device: BD0ED1A2-8CA2-4384-8211-A1655A5E2FC9 iPhone iOS 18.3 (phone)

        """
    }
}
