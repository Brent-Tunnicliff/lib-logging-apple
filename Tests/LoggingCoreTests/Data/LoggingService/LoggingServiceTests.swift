// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation
import SwiftData
import Testing

@testable import LoggingCore

struct LoggingServiceTests {
    private let loggingService: any LoggingService
    private let mockDeviceProvider = MockDeviceProvider()
    private let mockFileService = MockFileService()
    private let mockModelMapper = MockModelMapper()
    private let modelContainer: ModelContainer
    private let userDefaults = UserDefaults.forTest()

    private let message = "This message should be sent to the places"
    private let packageName = "LoggingTests"
    private let tag = LogTag(
        file: "file",
        function: "function",
        line: 1
    )
    private let timestamp = Date()

    init() async {
        self.modelContainer = .emptyInMemoryOnly()
        self.loggingService = DefaultLoggingService(
            deviceProvider: mockDeviceProvider,
            fileService: mockFileService,
            modelContainer: modelContainer,
            modelMapper: mockModelMapper,
            userDefaults: userDefaults
        )
    }

    @Test(arguments: product(LogLevel.allCases, [true, false]))
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

        userDefaults.minimalLogLevel = level
        try await performStoreLog(loggingService: loggingService, error: error, logLevel: level)
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
        userDefaults.minimalLogLevel = .info
        try await performStoreLog(loggingService: loggingService, logLevel: .debug)
        let result: [LogEntity] = try ModelContext(modelContainer).fetch(FetchDescriptor())
        #expect(result.isEmpty)
    }

    @Test
    func storeLogEqualToDefinedLogLevelIsStored() async throws {
        userDefaults.minimalLogLevel = .info
        try await performStoreLog(loggingService: loggingService, logLevel: .info)
        let result: [LogEntity] = try ModelContext(modelContainer).fetch(FetchDescriptor())
        #expect(!result.isEmpty)
    }

    private func performStoreLog(
        loggingService: any LoggingService,
        error: (any Error)? = nil,
        logLevel: LogLevel
    ) async throws {
        try await loggingService.storeLog(
            error: error,
            logLevel: logLevel,
            message: message,
            packageName: packageName,
            tag: tag,
            timestamp: timestamp
        )
    }
}
