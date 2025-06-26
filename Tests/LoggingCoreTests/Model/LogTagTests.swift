// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Testing

@testable import LoggingCore

struct LogTagTests {
    @Test(arguments: [
        (LogTag(file: "1", function: "1", line: 1), LogTag(file: "2", function: "1", line: 1)),
        (LogTag(file: "1", function: "1", line: 1), LogTag(file: "1", function: "2", line: 1)),
        (LogTag(file: "1", function: "1", line: 1), LogTag(file: "1", function: "1", line: 2)),
    ])
    func equatableDifferent(tag1: LogTag, tag2: LogTag) {
        #expect(tag1 != tag2)
    }

    @Test
    func equatableSame() {
        #expect(LogTag(file: "1", function: "1", line: 1) == LogTag(file: "1", function: "1", line: 1))
    }

    @Test
    func description() {
        let tag = LogTag(
            file: "file",
            function: "function",
            line: 1
        )
        #expect(tag.description == "file:function:1")
    }
}
