// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

public import SwiftUI

/// The toolbar item used for navigating to ``LogsView``.
public struct LogsViewToolbarItem: ToolbarContent {
    @Environment(\.logsViewPresentingStyle) var presentingStyle
    @State private var isNavigationDestinationPresented = false
    @State private var isSheetPresented = false

    #if os(macOS) || os(iOS)
        @Environment(\.openWindow) private var openWindow

        private var supportsWindow: Bool {
            #if os(iOS)
                UIApplication.shared.supportsMultipleScenes
            #elseif os(macOS)
                true
            #endif
        }
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
                        .toolbar {
                            Button {
                                isSheetPresented = false
                            } label: {
                                Image(systemName: "xmark")
                            }
                        }
                }
            }
        }
    }

    private func logsView() -> some View {
        LogsView()
    }

    private func performNavigationDestination() {
        isNavigationDestinationPresented = true
    }

    private func performModal() {
        #if os(iOS) || os(macOS)
            if supportsWindow {
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

extension View {
    /// Define the way clicking on ``LogsViewToolbarItem`` will present ``LogsView``.
    public func logsViewPresentingStyle(_ presentingStyle: LogsViewPresentingStyle) -> some View {
        environment(\.logsViewPresentingStyle, presentingStyle)
    }
}

extension EnvironmentValues {
    @Entry fileprivate var logsViewPresentingStyle: LogsViewPresentingStyle = .default
}

/// Defines the method used to present the ``LogsView``.
public struct LogsViewPresentingStyle: Sendable, Hashable {
    /// Presents ``LogsView`` via navigation.
    ///
    /// This must be wrapped within a `NavigationStack` or `NavigationView`. This is the default option.
    public static let navigationDestination = LogsViewPresentingStyle(wrapped: .navigationDestination)

    /// Presents ``LogsView`` modally.
    ///
    /// MacOS presents it as a Window, which requires adding ``LogsWindow`` to the app Scene.
    /// All other platforms present it as a sheet.
    public static let modal = LogsViewPresentingStyle(wrapped: .modal)

    let wrapped: Wrapped

    private init(wrapped: Wrapped) {
        self.wrapped = wrapped
    }

    enum Wrapped: Sendable, CaseIterable, Hashable {
        case navigationDestination
        case modal
    }
}

extension LogsViewPresentingStyle: CaseIterable {
    /// A type that provides a collection of all of its values.
    public static let allCases: [LogsViewPresentingStyle] = LogsViewPresentingStyle.Wrapped
        .allCases
        .map {
            switch $0 {
            case .modal: .modal
            case .navigationDestination: .navigationDestination
            }
        }
}

extension LogsViewPresentingStyle {
    /// Default presentation style.
    public static let `default`: LogsViewPresentingStyle = .modal
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
