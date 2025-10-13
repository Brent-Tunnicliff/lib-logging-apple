// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation
import LoggingCore
import SwiftData
import Testing

@Suite("SortDescriptor+LogEntityTests")
struct SortDescriptorLogEntityTests {
    // Initialising a `modelContext` to make sure there are no issues when we start creating LogEntities.
    private let modelContext = ModelContext(ModelContainer.emptyInMemoryOnly())

    @Test(arguments: LogEntityByDateAndIdArgument.allCases)
    func logEntityByDateAndId(_ argument: LogEntityByDateAndIdArgument) async throws {
        let sortDescriptors: [SortDescriptor<LogEntity>] = .byDateAndId(order: argument.order)
        let input = argument.input
        let expectedResult = argument.expectedResult

        // Validating the dynamic input data is valid.
        #expect(input.count > 1)
        #expect(Set(input.map(\.id)).count == input.count)

        let results = argument.input.sorted(using: sortDescriptors)
        #expect(results.count == input.count)

        for (offset, expectedLogEntity) in expectedResult.enumerated() {
            guard offset < results.count else {
                Issue.record("No value for index \(offset)")
                continue
            }

            let resultLogEntity = results[offset]
            #expect(resultLogEntity.id == expectedLogEntity.id)
            #expect(resultLogEntity.timestampCreated == expectedLogEntity.timestampCreated)
        }
    }
}

extension SortDescriptorLogEntityTests {
    enum LogEntityByDateAndIdArgument: CaseIterable {
        case forward
        case reverse

        var input: [LogEntity] {
            [
                logEntityOne,
                logEntityTwo,
                logEntityThree,
                logEntityFour,
                logEntityFive,
                logEntitySix,
                logEntitySeven,
                logEntityEight,
                logEntityNine,
                logEntityTen,
            ].shuffled()
        }

        var order: SortOrder {
            switch self {
            case .forward: .forward
            case .reverse: .reverse
            }
        }

        var expectedResult: [LogEntity] {
            switch self {
            case .forward:
                [
                    logEntityThree,
                    logEntitySeven,
                    logEntityTen,
                    logEntityNine,
                    logEntityEight,
                    logEntitySix,
                    logEntityFive,
                    logEntityFour,
                    logEntityTwo,
                    logEntityOne,
                ]
            case .reverse:
                // We expect the `reverse` order to literally be the opposite order to forward.
                // We don't have any other conditions.
                LogEntityByDateAndIdArgument.forward.expectedResult.reversed()
            }
        }
    }
}

extension SortDescriptorLogEntityTests.LogEntityByDateAndIdArgument {
    // MARK: - Test data

    fileprivate var logEntityOne: LogEntity {
        LogEntity.mock(
            id: UUID.forced(uuidString: "00000000-0000-0000-0000-000000000001"),
            timestampCreated: date(for: "2025-01-01T00:00:10Z")
        )
    }

    fileprivate var logEntityTwo: LogEntity {
        LogEntity.mock(
            id: UUID.forced(uuidString: "00000000-0000-0000-0000-000000000002"),
            timestampCreated: date(for: "2025-01-01T00:00:09Z")
        )
    }

    fileprivate var logEntityThree: LogEntity {
        LogEntity.mock(
            id: UUID.forced(uuidString: "00000000-0000-0000-0000-000000000003"),
            timestampCreated: date(for: "2025-01-01T00:00:01Z")
        )
    }

    fileprivate var logEntityFour: LogEntity {
        LogEntity.mock(
            id: UUID.forced(uuidString: "00000000-0000-0000-0000-000000000004"),
            timestampCreated: date(for: "2025-01-01T00:00:07Z")
        )
    }

    fileprivate var logEntityFive: LogEntity {
        LogEntity.mock(
            id: UUID.forced(uuidString: "00000000-0000-0000-0000-000000000005"),
            timestampCreated: date(for: "2025-01-01T00:00:06Z")
        )
    }

    fileprivate var logEntitySix: LogEntity {
        LogEntity.mock(
            id: UUID.forced(uuidString: "00000000-0000-0000-0000-000000000006"),
            timestampCreated: date(for: "2025-01-01T00:00:05Z")
        )
    }

    fileprivate var logEntitySeven: LogEntity {
        LogEntity.mock(
            id: UUID.forced(uuidString: "00000000-0000-0000-0000-000000000007"),
            timestampCreated: date(for: "2025-01-01T00:00:01Z")
        )
    }

    fileprivate var logEntityEight: LogEntity {
        LogEntity.mock(
            id: UUID.forced(uuidString: "00000000-0000-0000-0000-000000000008"),
            timestampCreated: date(for: "2025-01-01T00:00:03Z")
        )
    }

    fileprivate var logEntityNine: LogEntity {
        LogEntity.mock(
            id: UUID.forced(uuidString: "00000000-0000-0000-0000-000000000009"),
            timestampCreated: date(for: "2025-01-01T00:00:02Z")
        )
    }

    fileprivate var logEntityTen: LogEntity {
        LogEntity.mock(
            id: UUID.forced(uuidString: "00000000-0000-0000-0000-000000000010"),
            timestampCreated: date(for: "2025-01-01T00:00:01Z")
        )
    }

    private func date(for dateString: String) -> Date {
        do {
            return try Date.ISO8601FormatStyle().parse(dateString)
        } catch {
            preconditionFailure("Failed to parse date '\(dateString)' with error: \(error)")
        }
    }
}

extension UUID {
    fileprivate static func forced(uuidString: String) -> UUID {
        guard let id = UUID(uuidString: uuidString) else {
            preconditionFailure("Unexpected nil for UUID '\(uuidString)'")
        }

        return id
    }
}
