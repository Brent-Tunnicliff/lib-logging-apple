// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation

extension UUID {
    static func forced(uuidString: String) -> UUID {
        guard let id = UUID(uuidString: uuidString) else {
            preconditionFailure("Unexpected nil for UUID '\(uuidString)'")
        }

        return id
    }
}
