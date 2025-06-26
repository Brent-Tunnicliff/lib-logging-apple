// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation
package import SwiftData

extension ModelContainer {
    package static let shared: ModelContainer = {
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

#if DEBUG
    // MARK: - Mock

    extension ModelContainer {
        @MainActor
        package static func emptyInMemoryOnly(name: String = #function) -> ModelContainer {
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
        package func injectingMocks(logs: [LogEntity] = LogEntity.defaultMocks()) -> ModelContainer {
            for log in logs {
                mainContext.insert(log)
            }

            return self
        }
    }
#endif
