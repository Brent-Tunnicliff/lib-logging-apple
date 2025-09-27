// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation

/// Simple wrapper for `FileManager` and  `FileHandle` to make unit test mocking easier.
///
/// Decided to use URL over path string in a few functions to be a bit more type safe.
protocol FileManagerType {
    var temporaryDirectory: URL { get }

    func createFile(at url: URL, contents: Data?)
    func fileExists(at url: URL) -> Bool
    func getFileHandle(forWritingTo url: URL) throws -> any WritableFileHandleType
}

// MARK: - DefaultFileService

/// Simple wrapper for `FileManager`.
///
/// This should contain minimal logic as it is not planned to be unit tested.
final class DefaultFileManager: FileManagerType {
    private let fileManager = FileManager.default

    var temporaryDirectory: URL {
        fileManager.temporaryDirectory
    }

    func createFile(at url: URL, contents: Data?) {
        fileManager.createFile(atPath: url.absoluteString, contents: contents)
    }

    func fileExists(at url: URL) -> Bool {
        fileManager.fileExists(atPath: url.absoluteString)
    }

    func getFileHandle(forWritingTo url: URL) throws -> any WritableFileHandleType {
        try FileHandle(forWritingTo: url)
    }
}

// MARK: - FileHandle

/// General wrappings of `FileHandle` logic that are common across reading and writing.
///
/// Did not include `close()` as we are leaving it up to the `FileHandle` to own and manage the fileDescriptor.
protocol FileHandleType {}

/// Wrappings of `FileHandle` logic that are only usable when writing.
protocol WritableFileHandleType: FileHandleType {
    // Saves any buffer content to disk before returning.
    func synchronize() throws

    func write<DataType>(contentsOf: DataType) throws where DataType: DataProtocol
}

extension FileHandle: FileHandleType {}

extension FileHandle: WritableFileHandleType {}
