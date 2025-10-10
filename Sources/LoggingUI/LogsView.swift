// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import LoggingCore
import SwiftData
public import SwiftUI

/// Displays all logs captured.
public struct LogsView: View {
    static var title: Text {
        Text(.logsViewTitle)
    }

    @Environment(\.loggingModelContainer) private var loggingModelContainer
    @Environment(\.loggingService) private var loggingService
    @State private var pageNumber = 1

    /// The content and behaviour of the view.
    public var body: some View {
        LogsViewContent(pageNumber: $pageNumber)
            .modelContainer(loggingModelContainer)
            .navigationTitle(Self.title)
            .task {
                // Lets trigger save on appear to force sync any pending changes.
                do {
                    try await loggingService.save()
                } catch {
                    Logger.logging.error("Failed to save logs", error: error)
                }
            }
    }
}

/// Acts kinda like a form of pagination, the max number of logs to get per page.
///
/// We can potentially have many more logs than the user will scroll through,
/// so limiting how many we load based on how far the user has scrolled is probably good enough.
private struct LogsViewContent: View {
    private static var logsPerPage: Int {
        100
    }

    @Binding private var pageNumber: Int
    @Environment(\.modelContext) private var modelContext
    @Query private var logs: [LogEntity]
    @State private var numberOfLogs: Int?

    init(pageNumber: Binding<Int>) {
        precondition(pageNumber.wrappedValue > 0, "pageNumber '\(pageNumber)' must be greater than 0")
        self._pageNumber = pageNumber
        var fetchDescriptor = Self.baseFetchDescriptor()
        fetchDescriptor.fetchLimit = pageNumber.wrappedValue * Self.logsPerPage
        self._logs = Query(fetchDescriptor)
    }

    var body: some View {
        List {
            ForEach(logs) {
                LogItemView(log: $0)
            }

            endOfListView
        }
        .listStyle(.plain)
    }

    private var endOfListView: some View {
        Group {
            if let numberOfLogs, numberOfLogs <= (pageNumber * Self.logsPerPage) {
                Text(.logsViewEnd)
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            }
        }
        .onAppear {
            do {
                let logsCount = try modelContext.fetchCount(Self.baseFetchDescriptor())
                if numberOfLogs != logsCount {
                    numberOfLogs = logsCount
                }
                pageNumber += 1
            } catch {
                Logger.logging.error("Failed to fetch logs count", error: error)
            }
        }
    }

    private static func baseFetchDescriptor() -> FetchDescriptor<LogEntity> {
        FetchDescriptor(sortBy: LogEntity.sortedBy)
    }
}

#Preview("Default") {
    @Previewable @State var pageNumber = 1

    NavigationStack {
        LogsViewContent(pageNumber: $pageNumber)
    }
    .loggingModelContainer(mocked: .populated)
    .loggingService(PreviewLoggingService())
}

#Preview("Empty") {
    @Previewable @State var pageNumber = 1

    NavigationStack {
        LogsViewContent(pageNumber: $pageNumber)
    }
    .loggingModelContainer(mocked: .empty)
    .loggingService(PreviewLoggingService())
}

private final class PreviewLoggingService: LoggingService {
    func exportLogs() async throws -> URL { URL.temporaryDirectory }

    func save() async throws {}

    func storeLog(
        error: (any Error)?,
        logLevel: LoggingCore.LogLevel,
        message: String,
        packageName: String,
        tag: LoggingCore.LogTag,
        timestamp: Date,
        thread: String
    ) async {}
}
