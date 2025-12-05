// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation
import LoggingCore
import SwiftData
import Testing

struct LogEntityTests {
    @Test
    func debugDescriptionAll() {
        let entity = logEntity(withNil: false)
        let expectedResult = """
            {"device":{"identifierForVendor":"00000000-0000-0000-0000-000000000002","model":"iPhone","systemName":"iOS","systemVersion":"18.3","userInterfaceIdiom":"phone"},"id":"00000000-0000-0000-0000-000000000001","level":"info","message":"Testing debug description","packageName":"Logging","tag":{"file":"Logging/LogEntity.swift","function":"mock(file:function:line:)","line":76},"timestampCreated":"2025-01-01T00:00:00Z","error":{"type":"Mock","message":"Something went wrong (not really)","localizedDescription":"Something went wrong in locale"},"thread":"Main"}
            """
        #expect(entity.debugDescription == expectedResult)
    }

    @Test
    func debugDescriptionMinimal() {
        let entity = logEntity(withNil: true)
        let expectedResult = """
            {"device":{"userInterfaceIdiom":"phone"},"id":"00000000-0000-0000-0000-000000000001","level":"info","message":"Testing debug description","packageName":"Logging","tag":{"file":"Logging/LogEntity.swift","function":"mock(file:function:line:)","line":76},"timestampCreated":"2025-01-01T00:00:00Z","thread":"Main"}
            """
        #expect(entity.debugDescription == expectedResult)
    }

    private func logEntity(withNil: Bool) -> LogEntity {
        LogEntity(
            device: device(withNil),
            id: .forced(uuidString: "00000000-0000-0000-0000-000000000001"),
            level: .info,
            message: "Testing debug description",
            packageName: "Logging",
            tag: tag,
            timestampCreated: .forced(string: "2025-01-01T00:00:00Z"),
            error: withNil ? nil : error,
            thread: "Main"
        )
    }

    private func device(_ withNil: Bool) -> LogEntity.Device {
        LogEntity.Device(
            identifierForVendor: withNil ? nil : .forced(uuidString: "00000000-0000-0000-0000-000000000002"),
            model: withNil ? nil : "iPhone",
            systemName: withNil ? nil : "iOS",
            systemVersion: withNil ? nil : "18.3",
            userInterfaceIdiom: .phone
        )
    }

    private var error: LogEntity.Error {
        LogEntity.Error(
            type: "Mock",
            message: "Something went wrong (not really)",
            localizedDescription: "Something went wrong in locale"
        )
    }

    private var tag: LogEntity.Tag {
        LogEntity.Tag(
            file: "Logging/LogEntity.swift",
            function: "mock(file:function:line:)",
            line: 76
        )
    }
}
