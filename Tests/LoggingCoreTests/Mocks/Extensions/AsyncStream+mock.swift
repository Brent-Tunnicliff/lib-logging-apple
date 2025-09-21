// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

extension AsyncStream {
    static func mock(
        values: [Element],
        shouldComplete: Bool = true
    ) -> AsyncStream<Element> where Element: Sendable {
        AsyncStream { continuation in
            for value in values {
                continuation.yield(value)
            }

            if shouldComplete {
                continuation.finish()
            }
        }
    }

    static func mock(
        yieldValue: Bool = true,
        shouldComplete: Bool = true
    ) -> AsyncStream<Element> where Element == Void {
        mock(
            values: yieldValue ? [()] : [],
            shouldComplete: shouldComplete
        )
    }
}
