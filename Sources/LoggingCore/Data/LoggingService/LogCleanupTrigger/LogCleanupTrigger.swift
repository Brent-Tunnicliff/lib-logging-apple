// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation

protocol LogCleanupTrigger: Sendable {
    /// Will yield a value if cleanup should be performed.
    func registerForCleanup() -> AsyncStream<Void>

    /// Store log cleanup performed.
    ///
    /// This is very important to call as it affects how often `registerForCleanup()` returns.
    func storeLogCleanup(timestamp: Date)
}
