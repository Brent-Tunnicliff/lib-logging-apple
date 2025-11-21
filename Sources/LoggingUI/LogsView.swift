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
                toolbarMore
                toolbarCloseButton
            }
            .task(id: exporting) {
                guard exporting else {
                    return
                }

                await viewModel.performExport()
            }
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
            await viewModel.refresh(modelContext: modelContext)
        }
    }

    private var endOfListView: some View {
        VStack(alignment: .center) {
            switch viewModel.endOfListState {
            case .currentlyLoadingNextPage:
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            case .idle:
                EmptyView()
            case .loadingNextPageFailed:
                Text(.logsViewNextPageFailed)
                Button(.retryButton) {
                    viewModel.loadNextPage(modelContext: modelContext)
                }
                .buttonStyle(.glass)
            case .noMoreLogs:
                Text(.logsViewEnd)
                    .font(.footnote)
            }
        }
        .font(.footnote)
        .frame(maxWidth: .infinity, alignment: .center)
        .listRowSeparatorIfSupported(.hidden)
        .onAppear {
            viewModel.loadNextPage(modelContext: modelContext)
        }
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
                // Todo
                Text(verbatim: "Coming soon")
            } label: {
                Image(systemName: "line.3.horizontal.decrease")
            }

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
}

extension View {
    func listRowSeparatorIfSupported(_ visibility: Visibility) -> some View {
        #if os(tvOS) || os(watchOS)
            self
        #else
            listRowSeparator(visibility)
        #endif
    }

    var isNavigationSubtitleSupported: Bool {
        #if os(iOS) || os(macOS)
            true
        #else
            false
        #endif
    }

    func navigationSubtitleIfSupported(_ value: Text) -> some View {
        #if os(iOS) || os(macOS)
            navigationSubtitle(value)
        #else
            self
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
