// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation
import Synchronization

extension AsyncStream {
    /// Convenient wrapper for wrapping a single task and handling cancellations.
    ///
    /// If task throws it will also finish the stream (e.g. `CancellationError`).
    /// Immediately after the `build` function returns or throws, we finish the steam.
    @concurrent
    static func async(
        _ elementType: Element.Type = Element.self,
        bufferingPolicy limit: AsyncStream.Continuation.BufferingPolicy = .unbounded,
        _ build: @escaping @Sendable (AsyncStream.Continuation) async throws -> Void
    ) async -> AsyncStream {
        await withCheckedContinuation { checkedContinuation in
            Task {
                let isReady = IsReady()
                let stream = AsyncStream(elementType, bufferingPolicy: limit) { streamContinuation in
                    let task = Task {
                        async let action: Void = build(streamContinuation)
                        isReady.value = true
                        try? await action
                        streamContinuation.finish()
                    }

                    streamContinuation.onTermination = { _ in
                        task.cancel()
                    }
                }

                let start = Date()
                // If it takes more than 1 second then something is very wrong.
                let timeout = start.addingTimeInterval(1)

                while !isReady.value {
                    guard Date() < timeout else {
                        // Lets just crash debug builds, and let release builds continue with an invalid stream.
                        let message = "Waiting for AsyncStream.async reached timeout."
                        assertionFailure(message)
                        Logger.logging.critical(message)
                        break
                    }

                    do {
                        try await Task.sleep(for: .milliseconds(10))
                    } catch {
                        // If sleep fails then just break the loop.
                        break
                    }
                }

                checkedContinuation.resume(returning: stream)
            }
        }
    }

    // We needed to wrap `value` in a type to get around the `~Copyable` causing build errors.
    private final class IsReady: Sendable {
        private let atomicValue = Atomic<Bool>(false)
        var value: Bool {
            get { atomicValue.load(ordering: .sequentiallyConsistent) }
            set { atomicValue.store(newValue, ordering: .sequentiallyConsistent) }
        }

    }
}
