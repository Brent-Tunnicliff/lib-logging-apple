// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Logging
import LoggingUI
import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DemoEntity.id) private var demoEntities: [DemoEntity]
    @State private var presentingStyle: LogsViewPresentingStyle = .default
    @State private var showSendLogsSheet = false

    var body: some View {
        List {
            Section {
                // If this is nil, then there may be an issue with the two databases conflicting.
                Text(
                    "default_database_id_\(demoEntities.last?.id ?? "nil")",
                    bundle: .module,
                    comment: "Specifies the latest id from the default database."
                )
            }

            CaptureLogSection(presentingStyle: $presentingStyle)
        }
        .toolbar {
            LogsViewToolbarItem()
        }
        // We need to set `logsViewPresentingStyle` after the toolbar, otherwise it won't apply.
        .logsViewPresentingStyle(presentingStyle)
        .onAppear {
            // The only reason for this database is to make sure it does not conflict with the logging one.
            modelContext.insert(DemoEntity())

            do {
                try modelContext.save()
            } catch {
                Logger.app.error("Error saving default database", error: error)
            }
        }
    }
}

#Preview {
    @Previewable @State var presentingStyle = LogsViewPresentingStyle.modal

    NavigationStack {
        ContentView()
            .loggingModelContainer(mocked: .populated)
    }
}
