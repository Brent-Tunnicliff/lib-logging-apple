// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

public import SwiftUI

/// The toolbar item used for navigating to ``LogsView``.
public struct LogsViewToolbarItem: ToolbarContent {
    @Environment(\.logsViewPresentingStyle) var presentingStyle
    @State private var isNavigationDestinationPresented = false
    @State private var isSheetPresented = false

    #if os(macOS)
        @Environment(\.openWindow) private var openWindow
    #endif

    /// Initialise an instance of ``LogsViewToolbarItem``.
    public init() {}

    /// The composition of content that comprise the toolbar content.
    public var body: some ToolbarContent {
        ToolbarItem {
            Button {
                switch presentingStyle.wrapped {
                case .navigationDestination: performNavigationDestination()
                case .modal:
                    isSheetPresented = true
                }
            } label: {
                Image(systemName: "rectangle.and.text.magnifyingglass")
            }
            .navigationDestination(
                isPresented: $isNavigationDestinationPresented,
                destination: logsView
            )
            .sheet(
                isPresented: $isSheetPresented,
                content: logsView
            )
        }
    }

    private func logsView() -> some View {
        LogsView()
    }

    private func performNavigationDestination() {
        isNavigationDestinationPresented = true
    }

    private func performModal() {
        #if os(macOS)
            openWindow.logsWindow()
        #else
            isNavigationDestinationPresented = true
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
    @Entry fileprivate var logsViewPresentingStyle: LogsViewPresentingStyle = .navigationDestination
}

/// Defines the method used to present the ``LogsView``.
public struct LogsViewPresentingStyle: Sendable {
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

    enum Wrapped: Sendable {
        case navigationDestination
        case modal
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
}

#Preview("sheet") {
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
    .loggingModelContainer(mocked: .populated)
    .logsViewPresentingStyle(.modal)
}
