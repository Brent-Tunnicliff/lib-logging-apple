// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Synchronization
import Testing

@testable import LoggingCore

@Suite("AsyncStream+asyncTests")
struct AsyncStreamAsyncTests {
    @Test(
        .timeLimit(.minutes(1)),
        arguments: [false, true]
    )
    func asyncWrapper(throwsError: Bool) async {
        let testHelper = TestHelper<Int>()
        let stream = AsyncStream<Int>.async {
            try await testHelper.build(continuation: $0)
        }

        await testHelper.waitForBuildToBeReady()

        let task = Task {
            var result: [Int] = []
            for await value in stream {
                result.append(value)
            }
            return result
        }

        let expectedResults = [1, 20, 300]

        for number in expectedResults {
            testHelper.buildContinuation?.yield(number)
        }

        testHelper.completeBuild(withError: throwsError)

        await #expect(task.value == expectedResults)
    }
}

extension AsyncStreamAsyncTests {
    private final class TestHelper<Element>: Sendable {
        private let completeBuildContinuationMutex = Mutex<CheckedContinuation<Void, any Error>?>(nil)
        private var completeBuildContinuation: CheckedContinuation<Void, any Error>? {
            completeBuildContinuationMutex.withLock { $0 }
        }

        private let buildContinuationMutex = Mutex<AsyncStream<Element>.Continuation?>(nil)
        var buildContinuation: AsyncStream<Element>.Continuation? {
            buildContinuationMutex.withLock { $0 }
        }

        func build(continuation: AsyncStream<Element>.Continuation) async throws {
            buildContinuationMutex.withLock {
                $0 = continuation
            }

            // Wait for completion
            try await withCheckedThrowingContinuation { checkedContinuation in
                completeBuildContinuationMutex.withLock {
                    $0 = checkedContinuation
                }
            }
        }

        func waitForBuildToBeReady() async {
            await withCheckedContinuation { checkedContinuation in
                Task {
                    while buildContinuation == nil || completeBuildContinuation == nil {
                        try await Task.sleep(for: .milliseconds(100))
                    }

                    checkedContinuation.resume()
                }
            }
        }

        func completeBuild(withError: Bool) {
            if withError {
                completeBuildContinuation?.resume(throwing: MockError())
            } else {
                completeBuildContinuation?.resume()
            }
        }
    }
}
