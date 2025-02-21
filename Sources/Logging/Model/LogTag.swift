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

extension LogTag: Equatable {
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    ///
    /// - Returns: Boolean value indicating whether two values are equal.
    public static func == (lhs: LogTag, rhs: LogTag) -> Bool {
        lhs.description == rhs.description
    }
}

extension LogTag: Sendable {}

extension LogTag: CustomStringConvertible {
    /// A textual representation of this instance.
    public var description: String {
        "\(file):\(function):\(line)"
    }
}
