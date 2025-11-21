// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation
import LoggingCore
import Observation
import SwiftData
import SwiftUI

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
    var logs: [LogEntity] { get }
    var totalLogsCount: Int? { get }

    func loadNextPage(modelContext: ModelContext)
    func onAppear(modelContext: ModelContext) async
    func performExport() async
    func refresh(modelContext: ModelContext) async
}

enum EndOfLogsListState {
    case currentlyLoadingNextPage
    case idle
    case loadingNextPageFailed
    case noMoreLogs
}

// MARK: - Default

@Observable
final class DefaultLogsViewModel: LogsViewModel {
    private(set) var endOfListState: EndOfLogsListState = .idle
    private(set) var logs: [LogEntity] = []
    private(set) var totalLogsCount: Int?

    private let fetchLimit: Int
    private let loggingService: any LoggingService

    var isAtEndOfLogs: Bool {
        guard let totalLogsCount else {
            return false
        }

        return logs.count == totalLogsCount
    }

    convenience init() {
        self.init(
            fetchLimit: 100,
            loggingService: DefaultLoggingService.shared
        )
    }

    init(
        fetchLimit: Int,
        loggingService: any LoggingService
    ) {
        self.fetchLimit = fetchLimit
        self.loggingService = loggingService
    }

    // MARK: - LogsViewModel

    func loadNextPage(modelContext: ModelContext) {
        Logger.logging.info("Loading next page")
        endOfListState = .currentlyLoadingNextPage

        let newLogs: [LogEntity]
        do {
            newLogs = try fetchNextLogs(after: logs.last, modelContext: modelContext)
        } catch {
            Logger.logging.error("Failed to nod next page", error: error)
            endOfListState = .loadingNextPageFailed
            return
        }

        logs.append(contentsOf: newLogs)
        endOfListState = newLogs.count < fetchLimit ? .noMoreLogs : .idle
    }

    func onAppear(modelContext: ModelContext) async {
        Logger.logging.info("View appearing")
        await savePendingLogs()
        syncTotalLogsCount(modelContext: modelContext)
    }

    func performExport() async {
        Logger.logging.info("Performing export")

        do {
            // We assume we do not need to manually call `loggingService.save()` first
            // as it is the same data source.
            let url = try await loggingService.exportLogs()

            // TODO: Do stuff
            print(url.absoluteString)
        } catch {
            Logger.logging.error("Export failed", error: error)
        }
    }

    func refresh(modelContext: ModelContext) async {
        Logger.logging.info("Performing refresh")
        await savePendingLogs()
        syncTotalLogsCount(modelContext: modelContext)

        guard let before = logs.first else {
            Logger.logging.info("No logs, so refresh getting first page")
            loadNextPage(modelContext: modelContext)
            return
        }

        let fetchedLogs: [LogEntity]
        do {
            fetchedLogs = try fetchLatestLogs(before: before, modelContext: modelContext)
        } catch {
            Logger.logging.error("Failed to fetch latest logs", error: error)
            return
        }

        let oldestFetchedLog = fetchedLogs.max(by: { $0.timestampCreated < $1.timestampCreated })

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
        let predicate = after.map {
            let otherTimestampCreated = $0.timestampCreated
            let otherId = $0.id

            return #Predicate<LogEntity> { value in
                value.timestampCreated <= otherTimestampCreated && value.id < otherId
            }
        }

        return try getLogs(
            predicate: predicate,
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

    private func getLogs(
        predicate: Predicate<LogEntity>?,
        modelContext: ModelContext,
        limit: Int?
    ) throws -> [LogEntity] {
        var descriptor = FetchDescriptor<LogEntity>(predicate: predicate, sortBy: .byDateAndId(order: .reverse))
        descriptor.fetchLimit = limit
        let logs = try modelContext.fetch(descriptor)

        Logger.logging.info("Fetched \(logs.count) logs")
        Logger.logging.debug("Fetched logs: \(logs)")

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

final class PreviewLogsViewModel: LogsViewModel {
    let endOfListState: EndOfLogsListState
    let logs: [LogEntity]
    let totalLogsCount: Int?

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

    func loadNextPage(modelContext: ModelContext) {}
    func onAppear(modelContext: ModelContext) async {}
    func performExport() async {}
    func refresh(modelContext: ModelContext) async {
        try? await Task.sleep(for: .seconds(1))
    }
}

extension PreviewLogsViewModel.State {
    fileprivate var endOfListState: EndOfLogsListState {
        switch self {
        case .empty: .noMoreLogs
        case .loading: .currentlyLoadingNextPage
        case .populated: .idle
        case .nextPageFailed: .loadingNextPageFailed
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
