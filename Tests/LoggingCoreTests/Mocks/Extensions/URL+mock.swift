// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation

extension URL {
    static var mock: URL {
        let urlString = "www.tunnicliff.dev"
        guard let url = URL(string: urlString) else {
            preconditionFailure("Failed to create url from '\(urlString)'")
        }

        return url
    }
}
