// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import LoggingCore
import SwiftData
public import SwiftUI

extension EnvironmentValues {
    @Entry var loggingModelContainer: ModelContainer = .shared
}

// MARK: - Mock

/// Represents how to populate the mocked logging container.
public struct MockedLoggingModelContainerState: Sendable {
    /// Container to be created empty.
    public static let empty = MockedLoggingModelContainerState(wrapped: .empty)

    /// Container to be populated with a variety of entities.
    public static let populated = MockedLoggingModelContainerState(wrapped: .populated)

    fileprivate let wrapped: Wrapped

    fileprivate enum Wrapped: Sendable {
        case empty
        case populated
    }
}

extension View {
    /// Replaces the logging model container with a mocked in memory instance.
    /// - Parameters:
    ///   - state: State of the mock to be populated.
    ///   - name: Name to be used as part of the container. Defaults to the function that calls this.
    /// - Returns: self with the injected model container.
    public func loggingModelContainer(
        mocked state: MockedLoggingModelContainerState,
        name: String = #function
    ) -> some View {
        environment(\.loggingModelContainer, .emptyInMemoryOnly(name: name).injectingMocks(logs: state.entities))
    }
}

extension MockedLoggingModelContainerState {
    fileprivate var entities: [LogEntity] {
        switch wrapped {
        case .empty: []
        case .populated: LogEntity.defaultMocks()
        }
    }
}
