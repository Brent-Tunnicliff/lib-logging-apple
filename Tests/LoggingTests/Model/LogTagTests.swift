// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Testing

@testable import Logging

struct LogTagTests {
    @Test(arguments: [
        (LogTag(file: "1"), LogTag(file: "2")),
        (LogTag(function: "1"), LogTag(function: "2")),
        (LogTag(line: 1), LogTag(line: 2)),
    ])
    func equatableDifferent(tag1: LogTag, tag2: LogTag) {
        #expect(tag1 != tag2)
    }

    @Test(arguments: [
        (LogTag(file: "1"), LogTag(file: "1")),
        (LogTag(function: "1"), LogTag(function: "1")),
        (LogTag(line: 1), LogTag(line: 1)),
        (
            LogTag(
                file: "file",
                function: "function",
                line: 1
            ),
            LogTag(
                file: "file",
                function: "function",
                line: 1
            )
        ),
    ])
    func equatableSame(tag1: LogTag, tag2: LogTag) {
        #expect(tag1 == tag2)
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
