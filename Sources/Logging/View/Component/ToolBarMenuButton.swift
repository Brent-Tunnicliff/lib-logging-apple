// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import SwiftUI

/// A toolbar Menu button that works with any platform.
///
/// WatchOS uses a `Button` while all others use`Menu`.
/// WatchOS does not support `Menu` and the build fails if any use of it is in the app
/// even if wrapped with available.
/// So created this to isolate the compile conditions needed for this.
struct ToolBarMenuButton<ButtonLabel: View, Label: View>: View {
    private let buttonLabel: ButtonLabel
    private let label: Label

    init(
        @ViewBuilder buttonLabel: () -> ButtonLabel,
        @ViewBuilder label: () -> Label
    ) {
        self.buttonLabel = buttonLabel()
        self.label = label()
    }

    var body: some View {
        #if os(watchOS)
            toolBarItemWatchOS
        #else
            toolBarItemDefault
        #endif
    }

    #if os(watchOS)
        @State private var showPickerSheet: Bool = false

        @ViewBuilder
        private var toolBarItemWatchOS: some View {
            Button {
                showPickerSheet = true
            } label: {
                buttonLabel
            }
            .sheet(isPresented: $showPickerSheet) {
                label
            }
        }
    #else
        @ViewBuilder
        private var toolBarItemDefault: some View {
            Menu {
                label
            } label: {
                buttonLabel
            }
        }
    #endif
}
