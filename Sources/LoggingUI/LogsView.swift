// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import LoggingCore
import SwiftData
public import SwiftUI

/// Displays all logs captured.
public struct LogsView: View {
    static var title: Text {
        Text(
            "logs_view_title",
            bundle: .module,
            comment: "The title of the view that lists all logs."
        )
    }

    @Environment(\.loggingModelContainer) private var loggingModelContainer

    /// The content and behaviour of the view.
    public var body: some View {
        LogsViewContent()
            .modelContainer(loggingModelContainer)
            .navigationTitle(Self.title)
    }
}

private struct LogsViewContent: View {
    @Query(sort: \LogEntity.timestampCreated, order: .reverse) private var logs: [LogEntity]

    var body: some View {
        List {
            if logs.isEmpty {
                Text(
                    "logs_view_empty",
                    bundle: .module,
                    comment: "Informs the user that there are no logs available to show."
                )
            } else {
                ForEach(logs) {
                    LogItemView(log: $0)
                }
            }
        }
        .listStyle(.plain)
    }
}

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
