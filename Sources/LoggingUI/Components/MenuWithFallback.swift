// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import SwiftUI

/// Wrapper that allows using Menu on all platforms.
///
/// If a platform does not support Menu, it will fallback to using a button and sheet approach.
struct MenuWithFallback<Content, Label>: View where Content: View, Label: View {
    @State private var isFallbackPresented = false
    private let content: Content
    private let label: Label

    init(@ViewBuilder content: () -> Content, @ViewBuilder label: () -> Label) {
        self.content = content()
        self.label = label()
    }

    var body: some View {
        #if os(watchOS)
            fallbackContent
        #else
            Menu {
                content
            } label: {
                label
            }
        #endif

    }

    private var fallbackContent: some View {
        Button(action: { isFallbackPresented = true }, label: { label })
            .sheet(isPresented: $isFallbackPresented) {
                List {
                    content
                }
            }
    }
}
