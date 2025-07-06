// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

public import SwiftUI

/// Displays ``LogsView`` in its own window on MacOS, all other platforms return empty Scene.
public struct LogsWindow: Scene {
    fileprivate static let id = "logs_window"

    /// Initialise an instance of ``LogsWindow``.
    public init() {}

    /// The content and behaviour of the scene.
    public var body: some Scene {
        #if os(macOS)
            Window(LogsView.title, id: Self.id) {
                LogsView()
            }
        #endif
    }
}

#if os(macOS)
    extension OpenWindowAction {
        /// Triggers opening ``LogsWindow``.
        func logsWindow() {
            self(id: LogsWindow.id)
        }
    }
#endif
