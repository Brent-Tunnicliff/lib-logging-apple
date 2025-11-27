// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation
import LoggingCore
import Observation
import SwiftData
import SwiftUI
import UserDefaultsHelpers

// MARK: - Base

/// Contains the main logic and state for ``LogsView`` so that it can be unit testable and mocked for preview.
///
/// Since logs is a technical diagnostic tool, the more issues the use is having the more logs they will get.
/// Because of this I wanted to test extreme performance handling, for example if the app has generated 100,000 logs
/// within the time period we keep.
/// Since I found using `@Query` made the view near unusable I went with a simplified pagination implementation.
/// Only load a small number at a time in an infinite scroll situation, as if they have
/// massive amount of logs they can only view a small amount anyway.
/// To keep the solution much simpler I decided to still use the View's ModelContext for
/// getting logs to avoid Sendable complexity.
protocol LogsViewModel {
    var endOfListState: EndOfLogsListState { get }
    var isViewReady: Bool { get }
    var logs: [LogEntity] { get }
    var platformSupportsExporting: Bool { get }
    var searchText: String { get set }
    var showExportView: ExportFileState? { get set }
    var totalLogsCount: Int? { get }
    var viewCriticalLogs: Bool { get set }
    var viewDebugLogs: Bool { get set }
    var viewErrorLogs: Bool { get set }
    var viewInfoLogs: Bool { get set }

    func loadNextPage()
    func onAppear(modelContext: ModelContext) async
    func performExport() async
    func refresh() async
}

extension LogsViewModel {
    var platformSupportsExporting: Bool {
        #if os(tvOS)
            false
        #else
            true
        #endif
    }
}

enum EndOfLogsListState {
    case idle
    case loading
    case loadingFailed(any Error)
    case noMoreLogs
}

// MARK: - Default

@Observable
final class DefaultLogsViewModel: LogsViewModel {
    // MARK: - Properties

    private(set) var endOfListState: EndOfLogsListState = .idle
    @ObservationIgnored
    private(set) var isViewReady = false
    private(set) var logs: [LogEntity] = []
    var showExportView: ExportFileState?
    private(set) var totalLogsCount: Int?

    private let fetchLimit: Int
    private let loggingService: any LoggingService

    @ObservationIgnored
    private var injectedModelContext: ModelContext?
    private var modelContext: ModelContext? {
        guard let injectedModelContext else {
            // If this happens, something weird has happened.
            // Crash debug builds, otherwise log.
            let message = "Unexpected nil modelContext"
            assertionFailure(message)
            Logger.logging.critical(message)
            return nil
        }

        return injectedModelContext
    }

    var isAtEndOfLogs: Bool {
        guard let totalLogsCount else {
            return false
        }

        return logs.count == totalLogsCount
    }

    // MARK: Filters

    var searchText = "" {
        didSet { filterLogs() }
    }

    @ObservationIgnored
    @UserDefault
    var viewCriticalLogs: Bool {
        didSet { filterLogs() }
    }

    @ObservationIgnored
    @UserDefault
    var viewDebugLogs: Bool {
        didSet { filterLogs() }
    }

    @ObservationIgnored
    @UserDefault
    var viewErrorLogs: Bool {
        didSet { filterLogs() }
    }

    @ObservationIgnored
    @UserDefault
    var viewInfoLogs: Bool {
        didSet { filterLogs() }
    }

    // MARK: - init

    convenience init() {
        self.init(
            fetchLimit: 100,
            loggingService: DefaultLoggingService.shared,
            userDefaults: .standard
        )
    }

    init(
        fetchLimit: Int,
        loggingService: any LoggingService,
        userDefaults: UserDefaults
    ) {
        self.fetchLimit = fetchLimit
        self.loggingService = loggingService
        self._viewCriticalLogs = UserDefault(\.viewCriticalLogs, store: userDefaults)
        self._viewDebugLogs = UserDefault(\.viewDebugLogs, store: userDefaults)
        self._viewErrorLogs = UserDefault(\.viewErrorLogs, store: userDefaults)
        self._viewInfoLogs = UserDefault(\.viewInfoLogs, store: userDefaults)
    }

    // MARK: - LogsViewModel

    func loadNextPage() {
        guard isViewReady, let modelContext else {
            return
        }

        Logger.logging.info("Loading next page")
        endOfListState = .loading

        let newLogs: [LogEntity]
        do {
            newLogs = try fetchNextLogs(after: logs.last, modelContext: modelContext)
        } catch {
            Logger.logging.error("Failed to load next page", error: error)
            endOfListState = .loadingFailed(error)
            return
        }

        logs.append(contentsOf: newLogs)
        endOfListState = newLogs.count < fetchLimit ? .noMoreLogs : .idle
    }

    func onAppear(modelContext: ModelContext) async {
        Logger.logging.info("View appearing")
        if self.injectedModelContext != modelContext {
            self.injectedModelContext = modelContext
            logs = []
        }

        await savePendingLogs()
        syncTotalLogsCount(modelContext: modelContext)
        isViewReady = true
        loadNextPage()
    }

    func performExport() async {
        Logger.logging.info("Performing export")
        let exportFileState = ExportFileState()
        self.showExportView = exportFileState

        do {
            // We assume we do not need to manually call `loggingService.save()` first
            // as it is the same data source.
            let exportResult = try await loggingService.exportLogs()

            Task {
                for await value in exportResult.progress {
                    try Task.checkCancellation()
                    exportFileState.inject(progress: value)
                }
            }

            await exportFileState.inject(file: try exportResult.url.value)
        } catch {
            Logger.logging.error("Export failed", error: error)
            exportFileState.inject(error: error)
        }
    }

    func refresh() async {
        Logger.logging.info("Performing refresh")
        guard let modelContext else {
            return
        }

        await savePendingLogs()
        syncTotalLogsCount(modelContext: modelContext)

        guard let before = logs.first else {
            Logger.logging.info("No logs, so refresh getting first page")
            loadNextPage()
            return
        }

        let fetchedLogs: [LogEntity]
        do {
            fetchedLogs = try fetchLatestLogs(before: before, modelContext: modelContext)
        } catch {
            Logger.logging.error("Failed to fetch latest logs", error: error)
            return
        }

        guard let oldestFetchedLog = fetchedLogs.max(by: { $0.timestampCreated < $1.timestampCreated }) else {
            // If there are no logs, no need to continue.
            return
        }

        // We assume the logs always return sorted, so no need to compare the whole logs for finding duplicates.
        let logsToCompare = logs.filter {
            $0.timestampCreated <= oldestFetchedLog.timestampCreated
        }

        // We do not want to add duplicates that are already on the list.
        let newLogs = fetchedLogs.filter { fetchedLog in
            !logsToCompare.contains(where: { $0.id == fetchedLog.id })
        }

        // Add to start of list.
        logs.insert(contentsOf: newLogs, at: 0)
    }

    // MARK: - Private

    private func fetchNextLogs(after: LogEntity?, modelContext: ModelContext) throws -> [LogEntity] {
        let logLevelsToShow: [LogEntity.LogLevel] = [
            viewDebugLogs ? .debug : nil,
            viewInfoLogs ? .info : nil,
            viewErrorLogs ? .error : nil,
            viewCriticalLogs ? .critical : nil,
        ].compactMap { $0 }
        let basePredicate = LogEntity.filterByLevelPredicate(logLevelsToShow)

        let afterPredicate: Predicate<LogEntity>
        if let after {
            let otherTimestampCreated = after.timestampCreated
            let otherId = after.id

            afterPredicate = #Predicate { value in
                value.timestampCreated <= otherTimestampCreated && value.id < otherId
            }
        } else {
            afterPredicate = #Predicate { _ in true }
        }

        let searchPredicate: Predicate<LogEntity>
        if searchText.isEmpty {
            searchPredicate = #Predicate { _ in true }
        } else {
            searchPredicate = LogEntity.searchPredicate(searchText)
        }

        let finalPredicate = #Predicate<LogEntity> { log in
            basePredicate.evaluate(log)
                && afterPredicate.evaluate(log)
                && searchPredicate.evaluate(log)
        }

        return try getLogs(
            predicate: finalPredicate,
            modelContext: modelContext,
            limit: fetchLimit
        )
    }

    /// Fetches all logs that have a timestamp equal to, or newer to the `before` log.
    ///
    /// Due to how we sort the data and the async nature of the logs,
    /// we are returning the before entity in the queried response to account
    /// for the rare edge case of the fetch returning logs with the same time stamp.
    /// Caller will need to handle filtering data after.
    private func fetchLatestLogs(before: LogEntity, modelContext: ModelContext) throws -> [LogEntity] {
        let otherTimestampCreated = before.timestampCreated
        let predicate = #Predicate<LogEntity> { value in
            value.timestampCreated >= otherTimestampCreated
        }

        return try getLogs(
            predicate: predicate,
            modelContext: modelContext,
            limit: nil
        )
    }

    private func filterLogs() {
        logs = []
        loadNextPage()
    }

    private func getLogs(
        predicate: Predicate<LogEntity>?,
        modelContext: ModelContext,
        limit: Int?
    ) throws -> [LogEntity] {
        var descriptor = FetchDescriptor<LogEntity>(predicate: predicate, sortBy: .byDateAndId(order: .reverse))
        descriptor.fetchLimit = limit
        let logs = try modelContext.fetch(descriptor)

        Logger.logging.info("Fetched \(logs.count) logs")
        Logger.logging.debug("Fetched logs: \(logs.debugDescription)")

        return logs
    }

    /// Manually triggers a save of any pending logs processed in the logging service.
    private func savePendingLogs() async {
        Logger.logging.info("Saving pending logs")
        do {
            try await loggingService.save()
        } catch {
            Logger.logging.error("Failed to save pending logs", error: error)
        }
    }

    private func syncTotalLogsCount(modelContext: ModelContext) {
        Logger.logging.info("Syncing total logs count")
        do {
            let logsCount = try modelContext.fetchCount(FetchDescriptor<LogEntity>())
            guard totalLogsCount != logsCount else {
                return
            }

            totalLogsCount = logsCount
            return
        } catch {
            Logger.logging.error("Failed to fetch logs count", error: error)
        }
    }
}

// MARK: - Preview

@Observable
final class PreviewLogsViewModel: LogsViewModel {
    let endOfListState: EndOfLogsListState
    let isViewReady = true
    let logs: [LogEntity]
    var searchText = ""
    var showExportView: ExportFileState?
    let totalLogsCount: Int?
    var viewCriticalLogs = true
    var viewDebugLogs = true
    var viewErrorLogs = true
    var viewInfoLogs = true

    enum State: CaseIterable {
        case empty
        case loading
        case populated
        case nextPageFailed
    }

    init(_ state: State) {
        self.endOfListState = state.endOfListState
        self.logs = state.logs
        self.totalLogsCount = state.totalLogsCount
    }

    func loadNextPage() {}
    func onAppear(modelContext: ModelContext) async {}
    func performExport() async {}
    func refresh() async {
        try? await Task.sleep(for: .seconds(1))
    }
}

extension PreviewLogsViewModel.State {
    private struct ExampleError: Error {
        var localizedDescription: String { "An unexpected error occurred." }
    }

    fileprivate var endOfListState: EndOfLogsListState {
        switch self {
        case .empty, .populated: .noMoreLogs
        case .loading: .loading
        case .nextPageFailed: .loadingFailed(ExampleError())
        }
    }

    fileprivate var logs: [LogEntity] {
        switch self {
        case .empty, .loading, .nextPageFailed: []
        case .populated: .defaultMocks()
        }
    }

    fileprivate var totalLogsCount: Int {
        switch self {
        case .empty: 0
        case .loading, .nextPageFailed: 123_456_789
        case .populated: logs.count
        }
    }
}
