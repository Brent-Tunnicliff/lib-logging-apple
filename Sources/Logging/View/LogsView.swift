// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import SwiftData
public import SwiftUI

/// Displays all logs captured.
public struct LogsView: View {
    public init() {}

    public var body: some View {
        LogsViewContent()
            .modelContainer(for: LogEntity.self)
    }
}

private struct LogsViewContent: View {
    @Query(sort: \LogEntity.timestampCreated, order: .reverse) private var logs: [LogEntity]
    @State private var isFilterSheetShowing = false

    @UserDefault(key: \.logLevel) var logLevel

    public var body: some View {
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
        .toolbar {
            ToolbarItem {
                filterToolBarItem
            }
        }
    }

    @ViewBuilder
    private var filterToolBarItem: some View {
        Menu {
            Picker(selection: $logLevel) {
                ForEach(LogLevel.Wrapped.allCases, id: \.self) {
                    Text($0.label, bundle: .module)
                        .id($0)
                }
            } label: {
                Text(logLevel.label, bundle: .module)
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle")
        }
    }
}

extension LogLevel.Wrapped {
    fileprivate var label: LocalizedStringKey {
        switch self {
        case .debug: "log_level_debug"
        case .info: "log_level_info"
        case .error: "log_level_error"
        case .critical: "log_level_critical"
        }
    }
}

#if DEBUG
    #Preview("Default") {
        let container = LogEntity.mockContainer()

        NavigationStack {
            LogsViewContent()
                .modelContainer(container)
        }
    }

    #Preview("Empty") {
        let container = LogEntity.mockContainer(logs: [])

        NavigationStack {
            LogsViewContent()
                .modelContainer(container)
        }
    }
#endif
