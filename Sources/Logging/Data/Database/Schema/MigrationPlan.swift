// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import SwiftData

enum MigrationPlan: SchemaMigrationPlan {
    static let schemas: [any VersionedSchema.Type] = [
        SchemaV1.self
    ]

    static var stages: [MigrationStage] { [] }
}
