// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

package import Foundation
import SwiftData
import UniformTypeIdentifiers

package protocol LoggingService: Sendable {
    /// Exports all logs to file and returns file path.
    func exportLogs() async throws -> URL

    /// Saves all pending logs.
    func save() async throws

    /// Persists a new log object.
    func storeLog(
        error: (any Error)?,
        logLevel: LogLevel,
        message: String,
        packageName: String,
        tag: LogTag,
        timestamp: Date,
        thread: String
    ) async
}

package enum LoggingServiceError: Error {
    case exportFileExists
    case failedToConvertLogToData
    case failedToCreateFile
}

// MARK: - DefaultLoggingService

package actor DefaultLoggingService: ModelActor {
    package static let shared = DefaultLoggingService()
    static var logRetention: Duration { .days(90) }

    let modelContainer: ModelContainer
    let modelExecutor: any ModelExecutor

    private let dateProvider: any DateProvider
    private var cleanupTask: Task<Void, any Error>?
    private let currentDevice: Task<Device, Never>
    private let fileManager: any FileManagerType
    private let logsBatchSize = 10
    private let logCleanupTrigger: any LogCleanupTrigger
    private let modelMapper: any ModelMapper
    private let userDefaults: any UserDefaultsStore

    init(
        dateProvider: any DateProvider,
        deviceProvider: any DeviceProvider,
        fileManager: any FileManagerType,
        logCleanupTrigger: any LogCleanupTrigger,
        modelContainer: ModelContainer,
        modelMapper: any ModelMapper,
        userDefaults: any UserDefaultsStore
    ) {
        self.currentDevice = Task {
            await deviceProvider.currentDevice()
        }
        self.dateProvider = dateProvider
        self.fileManager = fileManager
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
            dateProvider: DefaultDateProvider.shared,
            deviceProvider: DefaultDeviceProvider(),
            fileManager: DefaultFileManager(),
            logCleanupTrigger: DefaultLogCleanupTrigger(),
            modelContainer: .shared,
            modelMapper: DefaultModelMapper(),
            userDefaults: UserDefaults.standard
        )
    }

    deinit {
        cleanupTask?.cancel()
    }

    private func registerForCleanup() {
        if let cleanupTask, !cleanupTask.isCancelled {
            // We do not want to trigger multiple tasks.
            Logger.logging.info("Unexpected additional call to 'registerForCleanup()'")
            return
        }

        Logger.logging.info("Registering for log cleanup events.")

        // Observe for cleanup of logs triggers.
        self.cleanupTask = Task { [weak self, logCleanupTrigger] in
            for await _ in await logCleanupTrigger.registerForCleanup() {
                try Task.checkCancellation()

                // If self is nil, then cancel.
                guard let self else {
                    throw CancellationError()
                }

                let (logRetentionSeconds, _) = Self.logRetention.components
                let olderThan = dateProvider.now(subtracting: TimeInterval(logRetentionSeconds))
                do {
                    Logger.logging.info("Deleting logs older than '\(olderThan.ISO8601Format())'")
                    try await deleteLogs(olderThan: olderThan)
                    await logCleanupTrigger.storeLogCleanup(timestamp: dateProvider.now)
                } catch {
                    // In the unexpected case of an error, lets just log it.
                    Logger.logging.critical("Failed to cleanup logs older than '\(olderThan)'", error: error)
                }
            }
        }
    }

    private func deleteLogs(olderThan timestamp: Date) throws {
        try modelContext.delete(
            model: LogEntity.self,
            where: #Predicate { $0.timestampCreated < timestamp }
        )
    }
}

// MARK: - LoggingService

extension DefaultLoggingService: LoggingService {
    package func exportLogs() throws -> URL {
        Logger.logging.info("Starting log export")

        // Save any pending changes before continuing.
        try save()

        // MARK: Create the export file

        let timestamp = dateProvider.now.ISO8601Format(.init(timeSeparator: .omitted))
        let bundleIdentifier = (Bundle.main.bundleIdentifier ?? "unknown")
            .replacingOccurrences(of: ".", with: "_")
        let exportFileName = "log_export_\(bundleIdentifier)_\(timestamp)_\(UUID().uuidString)"
        let temporaryDirectory = fileManager.temporaryDirectory
        let fileURL = temporaryDirectory.appending(path: exportFileName, directoryHint: .notDirectory)
            .appendingPathExtension(for: .plainText)

        // This should never happen, but if it does lets throw.
        guard !fileManager.fileExists(at: fileURL) else {
            Logger.logging.error("File already exists '\(fileURL.absoluteString)'")
            throw LoggingServiceError.exportFileExists
        }

        guard fileManager.createFile(at: fileURL, contents: "".data(using: .utf8)) else {
            Logger.logging.error("File failed to create '\(fileURL.absoluteString)'")
            throw LoggingServiceError.failedToCreateFile
        }

        // MARK: Populate the export

        let fileHandle = try fileManager.getFileHandle(forWritingTo: fileURL)
        var fetchDescriptor = FetchDescriptor<LogEntity>(sortBy: .byDateAndId())
        // Fetching with `batchSize` always throws if we include pending changes.
        fetchDescriptor.includePendingChanges = false
        let logs = try modelContext.fetch(fetchDescriptor, batchSize: logsBatchSize)
        for log in logs {
            let logExport = modelMapper.toExportContent(logEntity: log)
            guard let logExportData = logExport.data(using: .utf8) else {
                Logger.logging.error("Failed to export log content \(logExport)")
                throw LoggingServiceError.failedToConvertLogToData
            }

            try fileHandle.write(contentsOf: logExportData)
        }

        // Save any remaining contents to disk.
        try fileHandle.synchronize()
        return fileURL
    }

    package func save() throws {
        guard modelContext.hasChanges else {
            return
        }

        try modelContext.save()
    }

    package func storeLog(
        error: (any Error)?,
        logLevel: LogLevel,
        message: String,
        packageName: String,
        tag: LogTag,
        timestamp: Date,
        thread: String
    ) async {
        // TODO: Build minimum log level logic to only store the levels desired.
        guard userDefaults.minimalLogLevel.supportedLogsLevels.contains(logLevel) else {
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
            error: error.map(modelMapper.toEntity),
            thread: thread
        )

        modelContext.insert(model)
    }
}

// MARK: - Private

extension LogLevel {
    /// Returns the list of supported log levels when self is the minimum supported level.
    fileprivate var supportedLogsLevels: [LogLevel] {
        switch self {
        case .debug: LogLevel.allCases
        case .info: [.info, .error, .critical]
        case .error: [.error, .critical]
        case .critical: [.critical]
        }
    }
}
