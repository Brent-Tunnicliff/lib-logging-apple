// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation

protocol FileService: Sendable {
    var directory: URL { get }
}
