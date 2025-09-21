// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation
import Synchronization

protocol FileService: Sendable {
    var directory: URL { get }
}

// MARK: - DefaultFileService

final class DefaultFileService: FileService {
    // Wrapping `fileManager` in Mutex to make it sendable safe.
    // We do not want these calls to be async, as it will be used in an actor in
    // a way where we don't want to deal with await and reentry.
    private let fileManagerMutex = Mutex<FileManager>(.default)
    private var fileManager: FileManager {
        fileManagerMutex.withLock { $0 }
    }

    var directory: URL {
        fileManager.temporaryDirectory
    }
}
