// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation

extension Duration {
    var asTimeInterval: TimeInterval {
        let (seconds, attoseconds) = components
        // 1e+18 attoseconds in 1 second.
        let attosecondsInOneSecond: Double = 1_000_000_000_000_000_000
        let attosecondsDecimal = Double(attoseconds) / attosecondsInOneSecond
        return Double(seconds) + attosecondsDecimal
    }
}
