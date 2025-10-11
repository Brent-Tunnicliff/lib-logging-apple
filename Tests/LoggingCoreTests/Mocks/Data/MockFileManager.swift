// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation
import Synchronization

@testable import LoggingCore

final class MockFileManager: FileManagerType, Sendable {
    var temporaryDirectory: URL { .mock }

    func createFile(at url: URL, contents: Data?) -> Bool { true }

    func fileExists(at url: URL) -> Bool { false }

    func getFileHandle(forWritingTo url: URL) throws -> any WritableFileHandleType {
        MockWritableFileHandleType()
    }
}

final class MockWritableFileHandleType: WritableFileHandleType {
    func synchronize() throws {}
    func write<DataType>(contentsOf: DataType) throws where DataType: DataProtocol {}
}
