// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation
import Synchronization

final class MockAsyncStream<Element>: AsyncSequence {
    let continuation: AsyncStream<Element>.Continuation
    private let stream: AsyncStream<Element>

    init() {
        let (stream, continuation) = AsyncStream<Element>.makeStream()
        self.continuation = continuation
        self.stream = stream
    }

    func makeAsyncIterator() -> AsyncStream<Element>.AsyncIterator {
        stream.makeAsyncIterator()
    }
}

extension MockAsyncStream: Sendable where Element: Sendable {}
