// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation

final class MockFileService: FileService {
    var directory: URL { .mock }
}
