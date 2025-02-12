// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Logging
import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text(Example.shared.getMessage())
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
