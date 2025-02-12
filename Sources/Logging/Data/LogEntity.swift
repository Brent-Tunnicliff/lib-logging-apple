// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation
import SwiftData

@Model
final class LogEntity {
    @Attribute(.unique)
    var id = UUID()
    var level: LogLevel
    var message: String
    var packageName: String
    var tag: String
    var timestampCreated: Date
    var error: Error?

    init(
        level: LogLevel,
        message: String,
        packageName: String,
        tag: String,
        timestampCreated: Date,
        error: Error?
    ) {
        self.level = level
        self.message = message
        self.packageName = packageName
        self.tag = tag
        self.timestampCreated = timestampCreated
        self.error = error
    }

}

// MARK: - Nested Types

extension LogEntity {
    enum LogLevel: Codable {
        case critical
        case debug
        case error
        case info
        case warning
    }

    // Defined as a class to avoid infinite `Self` references in struct.
    final class Error: Codable {
        let type: String
        let message: String?
        let cause: Error?

        init(type: String, message: String?, cause: Error?) {
            self.type = type
            self.message = message
            self.cause = cause
        }
    }
}

// MARK: - Preview

#if DEBUG
    extension LogEntity {
        static func mock(
            level: LogLevel = .debug,
            message: String = "Mock log",
            packageName: String = "Logging",
            tag: String = "Tag",
            timestampCreated: Date = Date(),
            error: Error? = nil
        ) -> LogEntity {
            LogEntity(
                level: level,
                message: message,
                packageName: packageName,
                tag: tag,
                timestampCreated: timestampCreated,
                error: error
            )
        }

        @MainActor
        static func previewContainer(
            logs: [LogEntity] = [
                .mock(level: .critical),
                .mock(level: .debug),
                .mock(level: .error),
                .mock(level: .info),
                .mock(level: .warning),
                .mock(
                    message: """
                        This message is very long, so that we can test out wrapping and truncating logic.
                        Blah, blah, blah. How about this weather huh? It has been raining lots tonight.
                        Luckily it was not raining while I was outside.
                        """
                ),
                .mock(
                    tag: """
                        Wow, look at this very long tag. This probably should not every be this long.
                        I imagine a tag will be a single word or class name or something.
                        A long value like this is way too much.
                        """
                ),
                .mock(
                    error: .mock(cause: nil)
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
                            """,
                        cause: .mock(cause: .mock(cause: .mock(cause: .mock())))
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

    extension LogEntity.Error {
        static func mock(
            type: String = "Mock",
            message: String? = "Something went wrong (not really)",
            cause: LogEntity.Error? = .mock(message: "Hehe, this is the cause", cause: nil)
        ) -> LogEntity.Error {
            LogEntity.Error(
                type: type,
                message: message,
                cause: cause
            )
        }
    }
#endif
