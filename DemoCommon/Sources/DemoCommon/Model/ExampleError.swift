// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation

struct ExampleError: LocalizedError {
    var errorDescription: String? {
        "ExampleError: Something went wrong! \(UUID().uuidString)"
    }
}
