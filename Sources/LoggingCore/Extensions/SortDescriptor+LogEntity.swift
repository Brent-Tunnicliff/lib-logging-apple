// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

package import Foundation

extension [SortDescriptor<LogEntity>] {
    package static func byDateAndId(order: SortOrder = .forward) -> [SortDescriptor<LogEntity>] {
        [
            SortDescriptor(\.timestampCreated, order: order),
            SortDescriptor(\.id, order: order),
        ]
    }
}
