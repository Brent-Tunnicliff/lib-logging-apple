// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation

extension TimeInterval {
    init(duration: Duration) {
        self.init(duration.components.seconds)
    }
}
