// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import SwiftData
public import SwiftUI

private var container: ModelContainer {
    do {
        return try LogEntity.defaultContainer()
    } catch {
        preconditionFailure(
            "Unable to create logging database container with error: '\(error)' ('\(error.localizedDescription)')"
        )
    }
}

extension Scene {
    /// Sets the logging model container for persistent storage of logs.
    ///
    /// - Warning: This needs to be called ASAP, so add it to the apps WindowGroup.
    /// Also, this will crash if creating the container fails.
    public func loggingModelContainer() -> some Scene {
        modelContainer(container)
    }
}

#if DEBUG

    // MARK: - Mocks

    public struct MockedLoggingModelContainerState: Sendable {
        public static let `default` = MockedLoggingModelContainerState(wrapped: .default)
        public static let empty = MockedLoggingModelContainerState(wrapped: .empty)

        let wrapped: Wrapped

        enum Wrapped: Sendable {
            case `default`
            case empty
        }
    }

    extension MockedLoggingModelContainerState {
        @MainActor
        var entities: [LogEntity] {
            switch wrapped {
            case .default: LogEntity.defaultMocks
            case .empty: []
            }
        }
    }

    extension View {
        public func mockedLoggingModelContainer(state: MockedLoggingModelContainerState = .default) -> some View {
            modelContainer(LogEntity.mockContainer(logs: state.entities))
        }
    }

#endif
