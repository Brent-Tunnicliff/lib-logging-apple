// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation
import SwiftData

protocol LoggingService: Sendable {
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
    private let context: ModelContext?
    private let modelMapper: any ModelMapper
    private let userDefaults: UserDefaults
    private let deviceProvider: any DeviceProvider

    init(
        deviceProvider: any DeviceProvider,
        modelContainer: ModelContainer?,
        modelMapper: any ModelMapper,
        userDefaults: UserDefaults
    ) {
        self.deviceProvider = deviceProvider
        self.context = modelContainer.map(ModelContext.init)
        self.modelMapper = modelMapper
        self.userDefaults = userDefaults
    }

    init() {
        let modelContainer: ModelContainer?

        do {
            modelContainer = try LogEntity.defaultContainer()
        } catch {
            assertionFailure("Failed to initialise Logger with error: \(error) (\(error.localizedDescription))")
            modelContainer = nil
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

        guard let context else {
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

        context.insert(model)
        try context.save()
    }
}
