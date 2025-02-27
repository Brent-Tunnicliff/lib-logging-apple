// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

public import SwiftUI

public struct CommonScene: Scene {
    @Environment(\.scenePhase) private var scenePhase

    public init() {}

    public var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView()
            }
        }
        .loggingModelContainer()
        .onChange(of: scenePhase) { oldPhase, newPhase in
            Logger.app.info("Scene transitioned from \(oldPhase.logName) to \(newPhase.logName)")
        }
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
