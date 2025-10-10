// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation
import SwiftData

/// Simple database model to make sure that combining other databases with the logging
/// one does not cause unexpected issues.
///
/// If the lib database is not configured correctly, then it will try to use the `default.store` for the app.
/// This will cause conflicts and errors if the app then has its own database.
@Model
final class DemoEntity {
    private(set) var id: String

    init() {
        id = UUID().uuidString
    }
}
