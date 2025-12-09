// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import CommonUI
public import SwiftUI

extension SeperateWindowIfSupported.WindowType {
    static let logsWindow = SeperateWindowIfSupported.WindowType(LogsView.title, id: "logs_window") {
        LogsView()
    }
}

/// Used for displaying ``LogsView`` in its own window if supported by OS.
public struct LogsWindowGroup: Scene {
    /// Initialise an instance of ``LogsWindowGroup``.
    public init() {}

    /// The content and behaviour of the scene.
    public var body: some Scene {
        SeperateWindowIfSupported(windowType: .logsWindow)
    }
}
