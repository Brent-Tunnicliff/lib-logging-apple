// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Logging
import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
//            LogsView()

            Text(Device.current.identifierForVendor?.uuidString ?? "nil")
            Text(Device.current.model ?? "nil")
            Text(Device.current.systemName ?? "nil")
            Text(Device.current.systemVersion ?? "nil")
            Text(Device.current.userInterfaceIdiom.description)
        }
        .padding()
    }
}

#if DEBUG
    #Preview {
        ContentView()
    }
#endif
