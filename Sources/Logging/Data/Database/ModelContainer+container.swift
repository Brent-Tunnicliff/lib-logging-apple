// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation
import SwiftData
public import SwiftUI

extension ModelContainer {
    static let shared: ModelContainer = {
        do {
            let schema = Schema(versionedSchema: LatestSchema.self)
            // The configuration needs a name so it does not get applied to the app's default database.
            let configuration = ModelConfiguration("logging", schema: schema)
            return try ModelContainer(
                for: schema,
                migrationPlan: MigrationPlan.self,
                configurations: configuration
            )
        } catch {
            preconditionFailure("Failed to initialise Logger with error: '\(error.localizedDescription)' (\(error))")
        }
    }()
}

extension EnvironmentValues {
    /// Model container used by logging views.
    @Entry var loggingModelContainer: ModelContainer = .shared
}

#if DEBUG
    // MARK: - Mock

    /// Represents how to populate the mocked logging container.
    public struct MockedLoggingModelContainerState: Sendable {
        /// Container to be created empty.
        public static let empty = MockedLoggingModelContainerState(wrapped: .empty)

        /// Container to be populated with a variety of entities.
        public static let populated = MockedLoggingModelContainerState(wrapped: .populated)

        let wrapped: Wrapped

        enum Wrapped: Sendable {
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

    extension ModelContainer {
        @MainActor
        static func emptyInMemoryOnly(name: String = #function) -> ModelContainer {
            do {
                let container = try ModelContainer(
                    for: Schema(versionedSchema: LatestSchema.self),
                    configurations: ModelConfiguration(
                        "\(name)_\(UUID().uuidString)",
                        isStoredInMemoryOnly: true
                    )
                )

                return container
            } catch {
                preconditionFailure("Error creating preview model container for \(LogEntity.self)")
            }
        }

        @MainActor
        func injectingMocks(logs: [LogEntity] = LogEntity.defaultMocks()) -> ModelContainer {
            for log in logs {
                mainContext.insert(log)
            }

            return self
        }
    }

    extension MockedLoggingModelContainerState {
        var entities: [LogEntity] {
            switch wrapped {
            case .empty: []
            case .populated: LogEntity.defaultMocks()
            }
        }
    }
#endif
