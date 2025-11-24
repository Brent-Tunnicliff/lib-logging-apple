// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

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
    @State private var exporting = false
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
                toolbarSearchIfSupported
                toolbarMore
                toolbarCloseButton
            }
            .task(id: exporting) {
                guard exporting else {
                    return
                }

                await viewModel.performExport()
            }
            .searchable(text: $viewModel.searchText)
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
                    .progressViewStyle(CircularProgressViewStyle())
            case .idle:
                EmptyView()
            case let .loadingFailed(error):
                Text(.logsViewNextPageFailed(error: error.localizedDescription))
                Button(.retryButton, action: viewModel.loadNextPage)
                    .retryButtonStyle()
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

    @ToolbarContentBuilder
    private var toolbarCloseButton: some ToolbarContent {
        if presentingStyle.requiresCloseButton {
            ToolbarItem(placement: .closePlacement) {
                Button(role: .close, action: dismiss.callAsFunction)
            }
        }
    }

    private var toolbarFilter: some ToolbarContent {
        ToolbarItem(placement: .toolbarFilterPlacement) {
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
            .menuActionDismissBehavior(.disabledIfSupported)
        }
    }

    private var toolbarMore: some ToolbarContent {
        ToolbarItem {
            MenuWithFallback {
                Button {
                    exporting = true
                } label: {
                    Label(.exportTitle, systemImage: "square.and.arrow.up")
                }
                .disabled(exporting)
            } label: {
                Image(systemName: "ellipsis")
            }
        }
    }

    @ToolbarContentBuilder
    private var toolbarSearchIfSupported: some ToolbarContent {
        #if os(visionOS)
            DefaultToolbarItem(kind: .search, placement: .bottomBar)
        #elseif os(iOS)
            ToolbarSpacer(.fixed, placement: .bottomBar)
            DefaultToolbarItem(kind: .search, placement: .bottomBar)
        #else
            ToolbarItem {
                EmptyView()
            }
        #endif
    }
}

extension View {
    fileprivate func listRowSeparatorIfSupported(_ visibility: Visibility) -> some View {
        #if os(tvOS) || os(watchOS)
            self
        #else
            listRowSeparator(visibility)
        #endif
    }

    fileprivate var isNavigationSubtitleSupported: Bool {
        #if os(iOS) || os(macOS)
            true
        #else
            false
        #endif
    }

    fileprivate func navigationSubtitleIfSupported(_ value: Text) -> some View {
        #if os(iOS) || os(macOS)
            navigationSubtitle(value)
        #else
            self
        #endif
    }

    fileprivate func retryButtonStyle() -> some View {
        #if os(visionOS)
            buttonStyle(.bordered)
        #else
            buttonStyle(.glass)
        #endif
    }
}

extension ToolbarItemPlacement {
    fileprivate static var toolbarFilterPlacement: ToolbarItemPlacement {
        #if os(macOS) || os(tvOS)
            .automatic
        #else
            .bottomBar
        #endif
    }

    fileprivate static var closePlacement: ToolbarItemPlacement {
        #if os(watchOS)
            // WatchOS does not show the button by default for some reason,
            // so manually setting it.
            .topBarTrailing
        #else
            .automatic
        #endif
    }
}

extension MenuActionDismissBehavior {
    static var disabledIfSupported: MenuActionDismissBehavior {
        #if os(macOS) || os(watchOS)
            .automatic
        #else
            .disabled
        #endif
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
