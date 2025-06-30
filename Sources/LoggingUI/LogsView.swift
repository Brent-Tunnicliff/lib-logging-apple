// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import LoggingCore
import SwiftData
public import SwiftUI

/// Displays all logs captured.
public struct LogsView: View {
    @Environment(\.loggingModelContainer) private var loggingModelContainer

    /// The content and behaviour of the view.
    public var body: some View {
        LogsViewContent()
            .modelContainer(loggingModelContainer)
    }
}

private struct LogsViewContent: View {
    @Query(sort: \LogEntity.timestampCreated, order: .reverse) private var logs: [LogEntity]

    var body: some View {
        Group {
            List {
                if logs.isEmpty {
                    Text("logs_view_empty", bundle: .module)
                } else {
                    ForEach(logs) {
                        LogItemView(log: $0)
                    }
                }
            }
            .listStyle(.plain)
        }
        .navigationTitle(Text("logs_view_title", bundle: .module))
    }
}

#if DEBUG
    #Preview("Default") {
        NavigationStack {
            LogsViewContent()
        }
        .loggingModelContainer(mocked: .populated)
    }

    #Preview("Empty") {
        NavigationStack {
            LogsViewContent()
        }
        .loggingModelContainer(mocked: .empty)
    }
#endif
