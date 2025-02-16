// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import SwiftData

enum LogEntityMigrationPlan: SchemaMigrationPlan {
    static let schemas: [any VersionedSchema.Type] = [
        LogEntitySchemaV1.self
    ]

    static var stages: [MigrationStage] { [] }
}
