// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation
import LoggingCore
import RegexBuilder
import Testing

@Suite("Thread+nameForLogTests")
struct ThreadNameForLogTests {
    @MainActor
    @Test
    func currentThreadMain() {
        let result = Thread.nameForLog
        #expect(result == "Main")
    }

    @concurrent
    @Test
    func currentThreadBackground() async {
        // Expected format is 4 numbers with 0 padding, e.g. "0002".
        let regex = Regex {
            Anchor.startOfSubject

            Repeat(
                One(.digit),
                count: 4
            )

            Anchor.endOfSubject
        }

        let result = Thread.nameForLog
        #expect(result != "Main")
        #expect(result.wholeMatch(of: regex) != nil, "Result '\(result)' does not match regex.")
    }

    // We want to maintain the full thread number if it gets very large.
    // Probably won't ever happen, but better to be safe than loose digits.
    @Test
    func currentThreadLong() async {
        let thread = MockThread()
        let result = thread.nameForLog
        #expect(result == "12345678")
    }
}

private final class MockThread: Thread {
    override var isMainThread: Bool {
        false
    }

    override var description: String {
        "<NSThread: 0x600001709ac0>{number = 12345678, name = (null)}"
    }
}
