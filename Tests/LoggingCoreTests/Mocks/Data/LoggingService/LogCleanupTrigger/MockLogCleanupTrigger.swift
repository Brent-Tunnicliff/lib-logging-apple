// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation
import Synchronization

@testable import LoggingCore

final class MockLogCleanupTrigger: LogCleanupTrigger {
    // MARK: - registerForCleanup()

    typealias RegisterForCleanupResponse = @Sendable () -> AsyncStream<Void>
    private let registerForCleanupResponseMutex = Mutex<RegisterForCleanupResponse>({ .mock() })
    var registerForCleanupResponse: RegisterForCleanupResponse {
        get { registerForCleanupResponseMutex.withLock { $0 } }
        set { registerForCleanupResponseMutex.withLock { $0 = newValue } }
    }
    func registerForCleanup() -> AsyncStream<Void> {
        registerForCleanupResponse()
    }

    // MARK: - storeLogCleanup(timestamp:)

    struct StoreLogCleanupInput: Sendable {
        package let timestamp: Date
    }
    typealias StoreLogCleanupResponse = @Sendable (StoreLogCleanupInput) -> Void
    private let storeLogCleanupResponseMutex = Mutex<StoreLogCleanupResponse>({ _ in })
    var storeLogCleanupResponse: StoreLogCleanupResponse {
        get { storeLogCleanupResponseMutex.withLock { $0 } }
        set { storeLogCleanupResponseMutex.withLock { $0 = newValue } }
    }
    func storeLogCleanup(timestamp: Date) {
        storeLogCleanupResponse(
            StoreLogCleanupInput(timestamp: timestamp)
        )
    }
}
