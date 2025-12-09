// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import CommonUI
import LoggingCore
import SwiftData
import SwiftUI

struct LogsView: View {
    static var title: Text {
        Text(.logsViewTitle)
    }

    @Environment(\.loggingModelContainer) private var loggingModelContainer

    var body: some View {
        LogsViewContent(viewModel: DefaultLogsViewModel())
            .modelContainer(loggingModelContainer)
    }
}

private struct LogsViewContent: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.logsViewPresentingStyle) private var presentingStyle
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: any LogsViewModel

    init(viewModel: any LogsViewModel) {
        self._viewModel = State(wrappedValue: viewModel)
    }

    var body: some View {
        listOfLogs
            .navigationTitle(LogsView.title)
            .navigationSubtitleIfSupported(navigationSubtitleContent)
            .task {
                await viewModel.onAppear(modelContext: modelContext)
            }
            .toolbar {
                toolbarFilter

                if let searchPlacement = BottomToolbarSearchPlacementIfSupported(spaces: .leading) {
                    searchPlacement
                }

                toolbarMore
            }
            .searchable(text: $viewModel.searchText)
            .exportLogsSheet(exportFileState: $viewModel.showExportView)
    }

    private var listOfLogs: some View {
        List {
            Section {
                ForEach(viewModel.logs) {
                    LogItemView(log: $0)
                }

                endOfListView
            } header: {
                if isNavigationSubtitleSupported == false {
                    navigationSubtitleContent
                }
            }
        }
        .listStyle(.plain)
        .refreshable {
            await viewModel.refresh()
        }
    }

    private var endOfListView: some View {
        VStack(alignment: .center) {
            switch viewModel.endOfListState {
            case .loading:
                ProgressView()
            case .idle:
                EmptyView()
            case let .loadingFailed(error):
                Text(.logsViewNextPageFailed(error: error.localizedDescription))
                Button(.retryButton, action: viewModel.loadNextPage)
                    .buttonStyleGlassWithFallback()
            case .noMoreLogs:
                Text(.logsViewEnd)
                    .font(.footnote)
            }
        }
        .font(.footnote)
        .frame(maxWidth: .infinity, alignment: .center)
        .listRowSeparatorIfSupported(.hidden)
        .onAppear(perform: viewModel.loadNextPage)
    }

    private var navigationSubtitleContent: Text {
        Text((viewModel.totalLogsCount ?? 0).formatted(.number))
    }

    private var toolbarFilter: some ToolbarContent {
        ToolbarItem(placement: .bottomBarWithFallback()) {
            MenuWithFallback {
                Toggle(isOn: $viewModel.viewDebugLogs) {
                    Text(.logLevelDebug)
                }

                Toggle(isOn: $viewModel.viewInfoLogs) {
                    Text(.logLevelInfo)
                }

                Toggle(isOn: $viewModel.viewErrorLogs) {
                    Text(.logLevelError)
                }

                Toggle(isOn: $viewModel.viewCriticalLogs) {
                    Text(.logLevelCritical)
                }
            } label: {
                Image(systemName: "line.3.horizontal.decrease")
            }
            .menuActionDismissBehaviorDisabledIfSupported()
        }
    }

    @ToolbarContentBuilder
    private var toolbarMore: some ToolbarContent {
        if viewModel.platformSupportsExporting {
            ToolbarItem {
                MenuWithFallback {
                    AsyncButton {
                        await viewModel.performExport()
                    } label: {
                        Label(.exportTitle, systemImage: "square.and.arrow.up")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                }
            }
        }
    }
}

#Preview("Default") {
    NavigationStack {
        LogsViewContent(viewModel: PreviewLogsViewModel(.populated))
    }
}

#Preview("Empty") {
    NavigationStack {
        LogsViewContent(viewModel: PreviewLogsViewModel(.empty))
    }
}

#Preview("Loading") {
    NavigationStack {
        LogsViewContent(viewModel: PreviewLogsViewModel(.loading))
    }
}

#Preview("Next page failed") {
    NavigationStack {
        LogsViewContent(viewModel: PreviewLogsViewModel(.nextPageFailed))
    }
}
