// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

extension AsyncStream {
    /// Convenient wrapper for wrapping a single task and handling cancellations.
    ///
    /// If task throws it will also finish the stream (e.g. `CancellationError`).
    /// Immediately after the `build` function returns or throws, we finish the steam.
    static func async(
        _ elementType: Element.Type = Element.self,
        bufferingPolicy limit: AsyncStream.Continuation.BufferingPolicy = .unbounded,
        _ build: @escaping @Sendable (AsyncStream.Continuation) async throws -> Void
    ) -> AsyncStream {
        AsyncStream(elementType, bufferingPolicy: limit) { continuation in
            let task = Task {
                try? await build(continuation)
                continuation.finish()
            }

            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
}
