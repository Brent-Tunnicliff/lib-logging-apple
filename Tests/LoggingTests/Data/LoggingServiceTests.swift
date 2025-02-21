// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation
import SwiftData
import Testing

@testable import Logging

struct LoggingServiceTests {
    private let mockDeviceProvider = MockDeviceProvider()
    private let modelContainer: ModelContainer
    private let modelMapper: any ModelMapper = DefaultModelMapper()
    private let loggingService: any LoggingService
    private let userDefaults = UserDefaults.forTest()

    private let message = "This message should be sent to the places"
    private let packageName = "LoggingTests"
    private let tag = LogTag()
    private let timestamp = Date()

    init() async {
        self.modelContainer = await LogEntity.mockContainer()
        self.loggingService = DefaultLoggingService(
            deviceProvider: mockDeviceProvider,
            modelContainer: modelContainer,
            modelMapper: modelMapper,
            userDefaults: userDefaults
        )
    }

    @Test(arguments: product(LogLevel.allCases, [true, false]))
    func storeLog(level: LogLevel, sendError: Bool) async throws {
        let expectedDevice = await modelMapper.toEntity(mockDeviceProvider.current())
        let expectedLogLevel = modelMapper.toEntity(level)
        let expectedTag = modelMapper.toEntity(tag)
        let error = sendError ? MockError() : nil
        let expectedError = error.map(modelMapper.toEntity)

        userDefaults.logLevel = level.wrapped
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
        userDefaults.logLevel = .info
        try await performStoreLog(logLevel: .debug)
        let result: [LogEntity] = try ModelContext(modelContainer).fetch(FetchDescriptor())
        #expect(result.isEmpty)
    }

    @Test
    func storeLogEqualToDefinedLogLevelIsStored() async throws {
        userDefaults.logLevel = .info
        try await performStoreLog(logLevel: .info)
        let result: [LogEntity] = try ModelContext(modelContainer).fetch(FetchDescriptor())
        #expect(!result.isEmpty)
    }

    private func performStoreLog(
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
