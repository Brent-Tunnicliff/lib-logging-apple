// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation
import SwiftData

enum SchemaV1: VersionedSchema {
    static let models: [any PersistentModel.Type] = [
        LogEntityV1.self
    ]

    static var versionIdentifier: Schema.Version {
        Schema.Version(1, 0, 0)
    }
}
