// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

@testable import LoggingCore

extension LogTag {
    static func mock(
        file: StaticString = "file",
        function: StaticString = "function",
        line: UInt = 1
    ) -> LogTag {
        LogTag(
            file: file,
            function: function,
            line: line
        )
    }
}
