// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Logging
import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            LogsView()
        }
        .padding()
    }
}

#if DEBUG
    #Preview {
        ContentView()
            .mockedLoggingModelContainer()
    }
#endif
