// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

public import SwiftUI

extension View {
    /// Define the way clicking on ``LogsViewToolbarItem`` will present ``LogsView``.
    public func logsViewPresentingStyle(_ presentingStyle: LogsViewPresentingStyle) -> some View {
        environment(\.logsViewPresentingStyle, presentingStyle)
    }
}

extension EnvironmentValues {
    @Entry var logsViewPresentingStyle: LogsViewPresentingStyle = .default
}

/// Defines the method used to present the ``LogsView``.
public struct LogsViewPresentingStyle: Sendable, Hashable {
    /// Presents ``LogsView`` via navigation.
    ///
    /// This must be wrapped within a `NavigationStack` or `NavigationView`.
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

    enum Wrapped: Sendable, Hashable {
        case navigationDestination
        case modal
    }
}

extension LogsViewPresentingStyle {
    var requiresCloseButton: Bool {
        switch wrapped {
        case .modal: true
        case .navigationDestination: false
        }
    }
}

extension LogsViewPresentingStyle {
    /// Default presentation style.
    public static let `default`: LogsViewPresentingStyle = .modal
}
