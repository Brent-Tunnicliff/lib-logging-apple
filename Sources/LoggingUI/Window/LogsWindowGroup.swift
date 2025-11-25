// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

public import SwiftUI

/// Used for displaying ``LogsView`` in its own window if supported by OS.
public struct LogsWindowGroup: Scene {
    fileprivate static let id = "logs_window"

    /// Initialise an instance of ``LogsWindowGroup``.
    public init() {}

    /// The content and behaviour of the scene.
    public var body: some Scene {
        WindowGroup(LogsView.title, id: Self.id) {
            LogsView()
        }
    }
}

#if os(macOS) || os(iOS)
    extension OpenWindowAction {
        /// Triggers opening ``LogsWindowGroup``.
        func logsWindow() {
            self(id: LogsWindowGroup.id)
        }
    }
#endif
