// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Logging
import LoggingUI
import SwiftData
public import SwiftUI

/// Common scene for both the demo app and the watch companion.
public struct DemoScene: Scene {
    @Environment(\.scenePhase) private var scenePhase

    /// Initialise an instance of ``DemoScene``.
    public init() {}

    /// The content and behavior of the scene.
    public var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView()
            }
        }
        .modelContainer(for: DemoEntity.self)
        .onChange(of: scenePhase) { oldPhase, newPhase in
            Logger.app.info("Scene transitioned from \(oldPhase.logName) to \(newPhase.logName)")
        }

        // We must define this here in order to navigate to `LogsView` in MacOS.
        LogsWindowGroup()
    }
}

extension ScenePhase {
    fileprivate var logName: String {
        switch self {
        case .background: "background"
        case .inactive: "inactive"
        case .active: "active"
        @unknown default: "unknown"
        }
    }
}
