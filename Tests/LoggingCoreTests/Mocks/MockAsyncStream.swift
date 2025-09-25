// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation
import Synchronization

final class MockAsyncStream<Element: Sendable>: AsyncSequence, Sendable {
    private let continuationMutex = Mutex<AsyncStream<Element>.Continuation?>(nil)
    var continuation: AsyncStream<Element>.Continuation {
        guard let continuation = continuationMutex.withLock({ $0 }) else {
            preconditionFailure("continuation is nil")
        }

        return continuation
    }

    func makeAsyncIterator() -> AsyncStream<Element>.AsyncIterator {
        // Clear old value
        continuationMutex.withLock { $0 = nil }

        let stream = AsyncStream<Element> { continuation in
            continuationMutex.withLock { $0 = continuation }
        }

        return stream.makeAsyncIterator()
    }

    func waitForContinuation(timeout duration: Duration = .seconds(1)) async throws {
        let timeout = Date(timeIntervalSinceNow: Double(duration.components.seconds))
        while continuationMutex.withLock({ $0 == nil }) {
            guard Date() < timeout else {
                throw MockAsyncStreamError.waitForContinuationTimedOut
            }

            try await Task.sleep(for: .milliseconds(10))
        }
    }

    enum MockAsyncStreamError: Error {
        case waitForContinuationTimedOut
    }
}
