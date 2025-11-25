// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation
import UniformTypeIdentifiers

extension URL {
    enum Preview {
        static let google = generateURL(with: "www.google.com")
        static let textFile: URL = .temporaryDirectory
            .appending(component: "temp")
            .appendingPathExtension(for: .plainText)

        private static func generateURL(with urlString: StaticString) -> URL {
            guard let url = URL(string: urlString.description) else {
                preconditionFailure("Failed to create url from \"\(urlString)\"")
            }

            return url
        }
    }
}
