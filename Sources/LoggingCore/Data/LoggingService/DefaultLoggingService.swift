// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

package import Foundation
import SwiftData

package actor DefaultLoggingService: ModelActor {
    package static let shared = DefaultLoggingService()

    let modelContainer: ModelContainer
    let modelExecutor: any ModelExecutor

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
        self.init(
            deviceProvider: DefaultDeviceProvider(),
            modelContainer: .shared,
            modelMapper: DefaultModelMapper(),
            userDefaults: UserDefaults.standard
        )
    }
}

// MARK: - LoggingService

extension DefaultLoggingService: LoggingService {
    package func deleteLogs(olderThan timestamp: Date) async throws {
        // TODO: Implement deleting of old logs
        fatalError("Todo")
    }

    package func storeLog(
        error: (any Error)?,
        logLevel: LogLevel,
        message: String,
        packageName: String,
        tag: LogTag,
        timestamp: Date
    ) async throws {
        // TODO: Build minimum log level logic to only store the levels desired.
        guard logLevel >= userDefaults.minimalLogLevel else {
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
