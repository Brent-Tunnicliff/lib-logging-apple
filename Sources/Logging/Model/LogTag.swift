// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

/// Convenient way to capture and share auto captured data like file, function and line.
public struct LogTag {
    let file: StaticString
    let function: StaticString
    let line: UInt

    public init(
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        self.file = file
        self.function = function
        self.line = line
    }
}

extension LogTag: Sendable {}

extension LogTag: CustomStringConvertible {
    /// A textual representation of this instance.
    public var description: String {
        "\(file):\(function):\(line)"
    }
}
