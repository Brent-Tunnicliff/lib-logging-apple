// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

package protocol InternalLogger: Sendable {
    func log(
        level: LogLevel,
        _ message: String,
        tag: LogTag,
        error: (any Error)?
    )
}
