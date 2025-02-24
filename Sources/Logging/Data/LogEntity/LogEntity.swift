// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation
import SwiftData

typealias LogEntitySchema = LogEntitySchemaV1
typealias LogEntity = LogEntitySchema.LogEntity

// MARK: - ModelContainer

extension LogEntity {
    static func defaultContainer() throws -> ModelContainer {
        try ModelContainer(
            for: LogEntity.self,
            migrationPlan: LogEntityMigrationPlan.self
        )
    }
}

#if DEBUG
    // MARK: - Mock

    extension LogEntity {
        static func mock(
            device: Device = .mock(),
            level: LogLevel = .debug,
            message: String = "Mock log",
            packageName: String = "Logging",
            tag: LogEntity.Tag = .mock(),
            timestampCreated: Date = Date(),
            error: Error? = nil
        ) -> LogEntity {
            LogEntity(
                device: device,
                level: level,
                message: message,
                packageName: packageName,
                tag: tag,
                timestampCreated: timestampCreated,
                error: error
            )
        }
    }

    extension LogEntity.Device {
        static func mock(
            identifierForVendor: UUID? = UUID(),
            model: String? = "iPhone",
            systemName: String? = "iOS",
            systemVersion: String? = "18.3",
            userInterfaceIdiom: LogEntity.UserInterfaceIdiom = .phone
        ) -> LogEntity.Device {
            LogEntity.Device(
                identifierForVendor: identifierForVendor,
                model: model,
                systemName: systemName,
                systemVersion: systemVersion,
                userInterfaceIdiom: userInterfaceIdiom
            )
        }
    }

    extension LogEntity.Error {
        static func mock(
            type: String = "Mock",
            message: String = "Something went wrong (not really)"
        ) -> LogEntity.Error {
            LogEntity.Error(
                type: type,
                message: message
            )
        }
    }

    extension LogEntity.Tag {
        static func mock(
            file: String = "Logging/LogEntity.swift",
            function: String = "mock(file:function:line:)",
            line: UInt = 76
        ) -> LogEntity.Tag {
            LogEntity.Tag(
                file: file,
                function: function,
                line: line
            )
        }
    }

    extension LogEntity {
        @MainActor
        static func mockContainer(
            logs: [LogEntity] = [
                .mock(level: .critical),
                .mock(level: .debug),
                .mock(level: .error),
                .mock(level: .info),
                .mock(
                    message: """
                        This message is very long, so that we can test out wrapping and truncating logic.
                        Blah, blah, blah. How about this weather huh? It has been raining lots tonight.
                        Luckily it was not raining while I was outside.
                        """
                ),
                .mock(
                    tag: .mock(
                        file: """
                            Wow, look at this very long tag. This probably should not every be this long.
                            I imagine a tag will be a single word or class name or something.
                            """,
                        function: "A long value like this is way too much.",
                        line: 1_000_000
                    )
                ),
                .mock(
                    error: .mock()
                ),
                .mock(
                    error: .mock(
                        type: "Wow, this error has a very long type name :O",
                        message: """
                            Now we are testing out a very long error message name to see how it handles
                            wrapping and truncating values.
                            This could potentially be quite long as some system errors might be long.
                            """
                    )
                ),
            ]
        ) -> ModelContainer {
            do {
                let container = try ModelContainer(
                    for: LogEntity.self,
                    configurations: ModelConfiguration(isStoredInMemoryOnly: true)
                )

                for log in logs {
                    container.mainContext.insert(log)
                }

                return container
            } catch {
                preconditionFailure("Error creating preview model container for \(LogEntity.self)")
            }
        }
    }
#endif
