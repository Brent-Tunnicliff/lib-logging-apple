// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation
import LoggingCore

extension LogEntity {
    static var sortedBy: [SortDescriptor<LogEntity>] {
        [
            SortDescriptor(\.timestampCreated, order: .reverse),
            SortDescriptor(\.id, order: .forward),
        ]
    }
}
