// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation

enum ArgumentError: Error {
    case duplicateFlag(Flag)
    case invalidURL(String)
    case flagMissingValue(Flag)
}
