// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import LoggingUI
import SwiftData
import SwiftUI

struct ContentView: View {
    @Binding private var presentingStyle: LogsViewPresentingStyle
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DemoEntity.id) private var demoEntities: [DemoEntity]
    @State private var showSendLogsSheet = false

    init(presentingStyle: Binding<LogsViewPresentingStyle>) {
        self._presentingStyle = presentingStyle
    }

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
        .logsViewPresentingStyle(presentingStyle)
        .toolbar {
            LogsViewToolbarItem()
        }
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
        ContentView(presentingStyle: $presentingStyle)
            .loggingModelContainer(mocked: .populated)
    }
}
