// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

/// Convenient way to share auto captured data like file, function and line.
struct LogTag {
    let file: StaticString
    let function: StaticString
    let line: UInt
}

extension LogTag: Equatable {
    static func == (lhs: LogTag, rhs: LogTag) -> Bool {
        lhs.description == rhs.description
    }
}

extension LogTag: Sendable {}

extension LogTag: CustomStringConvertible {
    var description: String {
        "\(file):\(function):\(line)"
    }
}
