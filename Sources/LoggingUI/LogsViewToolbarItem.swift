// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

public import SwiftUI

/// The toolbar item used for navigating to ``LogsView``.
public struct LogsViewToolbarItem: ToolbarContent {
    @Environment(\.logsViewPresentingStyle) var presentingStyle
    @State private var isLogsViewPresented = false

    /// The composition of content that comprise the toolbar content.
    public var body: some ToolbarContent {
        ToolbarItem {
            applyingPresentingStyle(isPresented: $isLogsViewPresented) {
                Button {
                    isLogsViewPresented = true
                } label: {
                    Image(systemName: "rectangle.and.text.magnifyingglass")
                }
            } destination: {
                LogsView()
            }
        }
    }

    @ViewBuilder
    private func applyingPresentingStyle<Content: View, Destination: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: () -> Content,
        @ViewBuilder destination: @escaping () -> Destination
    ) -> some View {
        switch presentingStyle.wrapped {
        case .navigationDestination:
            content()
                .navigationDestination(isPresented: isPresented) {
                    destination()
                }
        case .sheet:
            content()
                .sheet(isPresented: isPresented) {
                    destination()
                }
        }
    }
}

extension View {
    func logsViewPresentingStyle(_ presentingStyle: LogsViewPresentingStyle) -> some View {
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

    /// Presents ``LogsView`` via a sheet.
    public static let sheet = LogsViewPresentingStyle(wrapped: .sheet)

    let wrapped: Wrapped

    private init(wrapped: Wrapped) {
        self.wrapped = wrapped
    }

    enum Wrapped: Sendable {
        case navigationDestination
        case sheet
    }
}

#if DEBUG
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
        .logsViewPresentingStyle(.sheet)
    }
#endif
