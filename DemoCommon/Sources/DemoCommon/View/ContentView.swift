// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Logging
import SwiftUI

struct ContentView: View {
    @State private var showSendLogsSheet = false

    var body: some View {
        VStack {
            LogsView()
        }
        .padding()
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
