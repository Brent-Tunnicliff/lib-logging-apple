// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

package import Foundation
import SwiftData

package protocol LoggingService: Sendable {
    func deleteLogs(olderThan timestamp: Date) async throws

    func exportLogs() async throws -> URL

    func storeLog(
        error: (any Error)?,
        logLevel: LogLevel,
        message: String,
        packageName: String,
        tag: LogTag,
        timestamp: Date
    ) async
}

// MARK: - DefaultLoggingService

package actor DefaultLoggingService: ModelActor {
    package static let shared = DefaultLoggingService()
    static var logRetention: Duration { .days(90) }

    let modelContainer: ModelContainer
    let modelExecutor: any ModelExecutor

    private var cleanupTask: Task<Void, any Error>?
    private let currentDevice: Task<Device, Never>
    private let fileService: any FileService
    private let logsBatchSize = 10
    private let logCleanupTrigger: any LogCleanupTrigger
    private let modelMapper: any ModelMapper
    private let userDefaults: UserDefaults

    init(
        deviceProvider: any DeviceProvider,
        fileService: any FileService,
        logCleanupTrigger: any LogCleanupTrigger,
        modelContainer: ModelContainer,
        modelMapper: any ModelMapper,
        userDefaults: UserDefaults
    ) {
        self.currentDevice = Task {
            await deviceProvider.currentDevice()
        }
        self.fileService = fileService
        self.logCleanupTrigger = logCleanupTrigger
        self.modelExecutor = DefaultSerialModelExecutor(
            modelContext: ModelContext(modelContainer)
        )
        self.modelContainer = modelContainer
        self.modelMapper = modelMapper
        self.userDefaults = userDefaults

        Task {
            await registerForCleanup()
        }
    }

    private init() {
        self.init(
            deviceProvider: DefaultDeviceProvider(),
            fileService: DefaultFileService(),
            logCleanupTrigger: DefaultLogCleanupTrigger(),
            modelContainer: .shared,
            modelMapper: DefaultModelMapper(),
            userDefaults: UserDefaults.standard
        )
    }

    deinit {
        cleanupTask?.cancel()
    }

    /// Manually trigger a save of any pending data.
    func save() throws {
        guard modelContext.hasChanges else {
            return
        }

        try modelContext.save()
    }

    private func registerForCleanup() async {
        if let cleanupTask, !cleanupTask.isCancelled {
            // We do not want to trigger multiple tasks.
            return
        }

        // Observe for cleanup of logs triggers.
        self.cleanupTask = Task { [weak self, logCleanupTrigger] in
            for await _ in logCleanupTrigger.registerForCleanup() {
                try Task.checkCancellation()

                // If self is nil, then cancel.
                guard let self else {
                    throw CancellationError()
                }

                let (logRetentionSeconds, _) = Self.logRetention.components
                let olderThan = Date().addingTimeInterval(-TimeInterval(logRetentionSeconds))
                do {
                    try await deleteLogs(olderThan: olderThan)
                    logCleanupTrigger.storeLogCleanup(timestamp: Date())
                } catch {
                    // In the unexpected case of an error, lets just log it.
                    await logIssue(
                        "Failed to cleanup logs older than '\(olderThan)'",
                        error: error,
                        logLevel: .critical
                    )
                }
            }
        }
    }

    private func logIssue(
        _ message: String,
        error: (any Error)?,
        logLevel: LogLevel,
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line
    ) async {
        await storeLog(
            error: error,
            logLevel: logLevel,
            message: message,
            packageName: "DefaultLoggingService",
            tag: LogTag(file: file, function: function, line: line),
            timestamp: Date()
        )
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
