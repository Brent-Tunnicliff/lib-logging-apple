// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

/// Convenient way to share auto captured data like file, function and line.
package struct LogTag {
    let file: StaticString
    let function: StaticString
    let line: UInt

    package init(file: StaticString, function: StaticString, line: UInt) {
        self.file = file
        self.function = function
        self.line = line
    }
}

// MARK: - CustomStringConvertible

extension LogTag: CustomStringConvertible {
    package var description: String {
        "\(file):\(function):\(line)"
    }
}

// MARK: - Equatable

extension LogTag: Equatable {
    package static func == (lhs: LogTag, rhs: LogTag) -> Bool {
        lhs.description == rhs.description
    }
}

// MARK: - Sendable

extension LogTag: Sendable {}
