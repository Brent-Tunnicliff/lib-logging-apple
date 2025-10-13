// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation
import Synchronization

@testable import LoggingCore

final class MockFileManager: FileManagerType, Sendable {
    var temporaryDirectory: URL { .mock }

    private let createFileInputMutex = Mutex<(URL, Data?)?>(nil)
    var createFileInput: (URL, Data?)? { createFileInputMutex.withLock { $0 } }
    func createFile(at url: URL, contents: Data?) -> Bool {
        createFileInputMutex.withLock { $0 = (url, contents) }
        return true
    }

    func fileExists(at url: URL) -> Bool { false }

    let mockWritableFileHandleType = MockWritableFileHandleType()
    func getFileHandle(forWritingTo url: URL) throws -> any WritableFileHandleType {
        mockWritableFileHandleType
    }
}

final class MockWritableFileHandleType: WritableFileHandleType, Sendable {
    private let synchronizeCalledAtomic = Atomic(false)
    var synchronizeCalled: Bool {
        synchronizeCalledAtomic.load(ordering: .sequentiallyConsistent)
    }
    func synchronize() throws {
        synchronizeCalledAtomic.store(true, ordering: .sequentiallyConsistent)
    }

    private let writeInputMutex = Mutex<[String]>([])
    var writeInput: [String] {
        writeInputMutex.withLock { $0 }
    }
    func write<DataType>(contentsOf data: DataType) throws where DataType: DataProtocol {
        let value = (data as? Data).map {
            String(data: $0, encoding: .utf8) ?? "<???>"
        }
        writeInputMutex.withLock { $0.append(value ?? "<???>") }
    }
}
