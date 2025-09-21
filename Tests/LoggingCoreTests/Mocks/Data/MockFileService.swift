// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation

@testable import LoggingCore

final class MockFileService: FileService {
    var directory: URL { .mock }
}
