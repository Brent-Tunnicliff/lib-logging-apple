// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Logging
import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showSendLogsSheet = false

    @Query(sort: \DemoEntity.id) private var demoEntities: [DemoEntity]

    var body: some View {
        VStack {
            Text("demo entity: \(demoEntities.first?.id ?? "nil")")

            LogsView()
        }
        .toolbar {
            ToolbarItem {
                Button {
                    showSendLogsSheet = true
                } label: {
                    Image(systemName: "paperplane")
                }
            }
        }
        .sheet(isPresented: $showSendLogsSheet) {
            CaptureLogView()
        }
        .onAppear {
            // The only reason for this database is to make sure it does not conflict with the logging one.
            modelContext.insert(DemoEntity())

            do {
                try modelContext.save()
            } catch {
                print("Error saving: \(error)")
            }
        }
    }
}

#if DEBUG
    #Preview {
        NavigationStack {
            ContentView()
                .loggingModelContainer(mocked: .populated)
        }
    }
#endif
