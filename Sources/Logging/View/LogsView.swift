// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import SwiftData
public import SwiftUI

/// Displays all logs captured.
public struct LogsView: View {
    public init() {}

    @UserDefault(key: \.logLevel) var logLevel

    public var body: some View {
        LogsViewContent(logLevel: $logLevel)
    }
}

private struct LogsViewContent: View {
    @Query private var logs: [LogEntity]
    @State private var isFilterSheetShowing = false
    @Binding private var logLevel: LogLevel.Wrapped

    init(logLevel: Binding<LogLevel.Wrapped>) {
        self._logLevel = logLevel
        let filteredLogLevels = logLevel.wrappedValue.allowedLevels.map(\.asEntity.rawValue)
        self._logs = Query(
            filter: #Predicate<LogEntity> { log in
                filteredLogLevels.contains(log.levelRawValue)
            },
            sort: \LogEntity.timestampCreated,
            order: .reverse
        )
    }

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
                ToolBarMenuButton {
                    filterIcon
                } label: {
                    filterPicker
                }

            }
        }
    }

    @ViewBuilder
    private var filterIcon: some View {
        Image(systemName: "line.3.horizontal.decrease.circle")
    }

    @ViewBuilder
    private var filterPicker: some View {
        Picker(selection: $logLevel) {
            ForEach(LogLevel.Wrapped.allCases, id: \.self) {
                Text($0.label, bundle: .module)
                    .tag($0)
            }
        } label: {
            Text(logLevel.label, bundle: .module)
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

    fileprivate var asEntity: LogEntity.LogLevel {
        switch self {
        case .debug: .debug
        case .info: .info
        case .error: .error
        case .critical: .critical
        }
    }
}

#if DEBUG
    #Preview("Default") {
        @Previewable @State var logLevel: LogLevel.Wrapped = .debug

        NavigationStack {
            LogsViewContent(logLevel: $logLevel)
                .mockedLoggingModelContainer()
        }
    }

    #Preview("Empty") {
        @Previewable @State var logLevel: LogLevel.Wrapped = .debug

        NavigationStack {
            LogsViewContent(logLevel: $logLevel)
                .mockedLoggingModelContainer(state: .empty)
        }
    }
#endif
