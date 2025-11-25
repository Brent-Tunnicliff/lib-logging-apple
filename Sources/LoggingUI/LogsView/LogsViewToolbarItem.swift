// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

public import SwiftUI

/// The toolbar item used for navigating to ``LogsView``.
public struct LogsViewToolbarItem: ToolbarContent {
    @Environment(\.logsViewPresentingStyle) var presentingStyle
    @State private var isNavigationDestinationPresented = false
    @State private var isSheetPresented = false

    #if os(macOS) || os(iOS)
        @Environment(\.openWindow) private var openWindow
    #endif

    /// Initialise an instance of ``LogsViewToolbarItem``.
    public init() {}

    /// The composition of content that comprise the toolbar content.
    public var body: some ToolbarContent {
        ToolbarItem(placement: .logsViewPlacement) {
            Button {
                switch presentingStyle.wrapped {
                case .navigationDestination:
                    performNavigationDestination()
                case .modal:
                    performModal()
                }
            } label: {
                Image(systemName: "rectangle.and.text.magnifyingglass")
            }
            .navigationDestination(isPresented: $isNavigationDestinationPresented) {
                LogsView()
            }
            .sheet(isPresented: $isSheetPresented) {
                NavigationStack {
                    LogsView()
                }
                .presentationDragIndicator(.visible)
            }
        }
    }

    private func performNavigationDestination() {
        isNavigationDestinationPresented = true
    }

    private func performModal() {
        #if os(iOS) || os(macOS)
            if WindowMode.isSupported {
                openWindow.logsWindow()
            } else {
                isSheetPresented = true
            }
        #else
            isSheetPresented = true
        #endif
    }
}

extension ToolbarItemPlacement {
    fileprivate static var logsViewPlacement: ToolbarItemPlacement {
        #if os(watchOS)
            // WatchOS does not show the button by default for some reason,
            // so manually setting it.
            .topBarTrailing
        #else
            .automatic
        #endif
    }
}

#Preview("navigationDestination") {
    NavigationStack {
        List {
            Text(verbatim: "Hello world!")
        }
        .toolbar {
            LogsViewToolbarItem()

            ToolbarItem {
                Button {
                } label: {
                    Image(systemName: "gearshape")
                }
            }
        }
    }
    .loggingModelContainer(mocked: .populated)
    .logsViewPresentingStyle(.navigationDestination)
}

#Preview("sheet") {
    NavigationStack {
        List {
            Text(verbatim: "Hello world!")
        }
        .toolbar {
            LogsViewToolbarItem()

            ToolbarItem {
                Button {
                } label: {
                    Image(systemName: "gearshape")
                }
            }
        }
    }
    .loggingModelContainer(mocked: .populated)
    .logsViewPresentingStyle(.modal)
}
