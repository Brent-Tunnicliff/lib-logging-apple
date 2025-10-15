// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation
import Synchronization

final class MockAsyncStream<Element>: AsyncSequence {
    private let stream: AsyncStream<Element>
    private let continuationMutex: Mutex<AsyncStream<Element>.Continuation?>
    var continuation: AsyncStream<Element>.Continuation {
        guard let continuation = continuationMutex.withLock({ $0 }) else {
            preconditionFailure("continuation is nil")
        }

        return continuation
    }

    init() {
        let continuationMutex = Mutex<AsyncStream<Element>.Continuation?>(nil)
        let stream = AsyncStream<Element> { continuation in
            continuationMutex.withLock { $0 = continuation }
        }
        self.continuationMutex = continuationMutex
        self.stream = stream

        let start = Date()
        while self.continuationMutex.withLock({ $0 == nil }) {
            guard Date().timeIntervalSince(start) < 1 else {
                preconditionFailure("MockAsyncStream.init timed out")
            }

            Thread.sleep(forTimeInterval: 0.01)
        }
    }

    func makeAsyncIterator() -> AsyncStream<Element>.AsyncIterator {
        stream.makeAsyncIterator()
    }

    enum MockAsyncStreamError: Error {
        case waitForContinuationTimedOut
    }
}

extension MockAsyncStream: Sendable where Element: Sendable {}
