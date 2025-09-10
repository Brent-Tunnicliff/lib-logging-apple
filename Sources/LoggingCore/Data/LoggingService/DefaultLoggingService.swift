// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

package import Foundation
import SwiftData

package actor DefaultLoggingService: ModelActor {
    package static let shared = DefaultLoggingService()

    let modelContainer: ModelContainer
    let modelExecutor: any ModelExecutor

    private let currentDevice: Task<Device, Never>
    private let fileService: any FileService
    private let logsBatchSize = 10
    private let modelMapper: any ModelMapper
    private let userDefaults: UserDefaults

    init(
        deviceProvider: any DeviceProvider,
        fileService: any FileService,
        modelContainer: ModelContainer,
        modelMapper: any ModelMapper,
        userDefaults: UserDefaults
    ) {
        self.currentDevice = Task {
            await deviceProvider.currentDevice()
        }
        self.fileService = fileService
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
            fileService: DefaultFileService(),
            modelContainer: .shared,
            modelMapper: DefaultModelMapper(),
            userDefaults: UserDefaults.standard
        )
    }

    /// Manually trigger a save of any pending data.
    func save() throws {
        guard modelContext.hasChanges else {
            return
        }

        try modelContext.save()
    }
}

// MARK: - LoggingService

extension DefaultLoggingService: LoggingService {
    package func deleteLogs(olderThan timestamp: Date) throws {
        try modelContext.delete(
            model: LogEntity.self,
            where: #Predicate { $0.timestampCreated < timestamp }
        )
    }

    package func exportLogs() throws -> URL {
        // TODO: Implement export
        fatalError("Not yet implemented")

        // var logs = try await getLogsPagination().makeIterator()
        // let firstLog = logs.next()

        // for log in logs {

        // }
    }

    package func storeLog(
        error: (any Error)?,
        logLevel: LogLevel,
        message: String,
        packageName: String,
        tag: LogTag,
        timestamp: Date
    ) async {
        // TODO: Build minimum log level logic to only store the levels desired.
        guard logLevel >= userDefaults.minimalLogLevel else {
            return
        }

        let device = await currentDevice.value
        let model = LogEntity(
            device: modelMapper.toEntity(device: device),
            level: modelMapper.toEntity(logLevel: logLevel),
            message: message,
            packageName: packageName,
            tag: modelMapper.toEntity(logTag: tag),
            timestampCreated: timestamp,
            error: error.map(modelMapper.toEntity)
        )

        modelContext.insert(model)
    }
}

// MARK: - Private

extension DefaultLoggingService {
    private func getLogsPagination() async throws -> FetchResultsCollection<LogEntity> {
        try modelContext.fetch(
            FetchDescriptor<LogEntity>(
                sortBy: [SortDescriptor(\LogEntity.timestampCreated)]
            ),
            batchSize: logsBatchSize
        )
    }
}
