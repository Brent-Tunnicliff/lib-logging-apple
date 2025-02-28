// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation
import SwiftData

protocol LoggingService: Sendable, ModelActor {
    func deleteLogs(olderThan timestamp: Date) async throws

    func storeLog(
        error: (any Error)?,
        logLevel: LogLevel,
        message: String,
        packageName: String,
        tag: LogTag,
        timestamp: Date
    ) async throws
}

actor DefaultLoggingService: LoggingService {
    static let shared = DefaultLoggingService()

    nonisolated let modelContainer: SwiftData.ModelContainer
    nonisolated let modelExecutor: any SwiftData.ModelExecutor

    private let modelMapper: any ModelMapper
    private let userDefaults: UserDefaults
    private let deviceProvider: any DeviceProvider

    init(
        deviceProvider: any DeviceProvider,
        modelContainer: ModelContainer,
        modelMapper: any ModelMapper,
        userDefaults: UserDefaults
    ) {
        self.deviceProvider = deviceProvider
        self.modelExecutor = DefaultSerialModelExecutor(
            modelContext: ModelContext(modelContainer)
        )
        self.modelContainer = modelContainer
        self.modelMapper = modelMapper
        self.userDefaults = userDefaults
    }

    private init() {
        let modelContainer: ModelContainer

        do {
            modelContainer = try LogEntity.defaultContainer()
        } catch {
            preconditionFailure("Failed to initialise Logger with error: \(error) (\(error.localizedDescription))")
        }

        self.init(
            deviceProvider: DefaultDeviceProvider(),
            modelContainer: modelContainer,
            modelMapper: DefaultModelMapper(),
            userDefaults: UserDefaults.standard
        )
    }

    func deleteLogs(olderThan timestamp: Date) async throws {
        // TODO: Implement deleting of old logs
        fatalError("Todo")
    }

    func storeLog(
        error: (any Error)?,
        logLevel: LogLevel,
        message: String,
        packageName: String,
        tag: LogTag,
        timestamp: Date
    ) async throws {
        // TODO: Build minimum log level logic to only store the levels desired.
        guard userDefaults.logLevel <= logLevel.wrapped else {
            return
        }

        let device = await deviceProvider.current()
        let model = LogEntity(
            device: modelMapper.toEntity(device),
            level: modelMapper.toEntity(logLevel),
            message: message,
            packageName: packageName,
            tag: modelMapper.toEntity(tag),
            timestampCreated: timestamp,
            error: error.map(modelMapper.toEntity)
        )

        modelExecutor.modelContext.insert(model)
        try modelExecutor.modelContext.save()
    }
}
