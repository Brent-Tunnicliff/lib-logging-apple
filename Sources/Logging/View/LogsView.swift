// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import SwiftData
public import SwiftUI

/// Displays all logs captured.
public struct LogsView: View {
    public init() {}

    public var body: some View {
        LogsViewContent()
            .modelContainer(for: LogEntity.self)
    }
}

private struct LogsViewContent: View {
    @Query var logs: [LogEntity]

    public var body: some View {
        List(logs) { log in
            Text(log.message)
        }
    }
}

#if DEBUG
    #Preview {
        let container = LogEntity.mockContainer()

        LogsViewContent()
            .modelContainer(container)
    }
#endif
