// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import SwiftUI

struct AsyncButton<Label>: View where Label: View {
    private let action: () async -> Void
    private let label: Label
    private let priority: TaskPriority
    @State private var isPerformingTask = false

    init(
        priority: TaskPriority = .userInitiated,
        action: @escaping () async -> Void,
        @ViewBuilder label: () -> Label
    ) {
        self.action = action
        self.label = label()
        self.priority = priority
    }

    var body: some View {
        Button {
            withAnimation {
                isPerformingTask = true
            }
        } label: {
            // We want the button to stay the size of the label,
            // so using opacity and overlay instead of simple if else.
            label
                .opacity(isPerformingTask ? 0 : 1)
                .overlay {
                    if isPerformingTask {
                        ProgressView()
                    }
                }
        }
        .disabled(isPerformingTask)
        .task(id: isPerformingTask, priority: priority) {
            guard isPerformingTask else {
                return
            }

            await action()
            withAnimation {
                isPerformingTask = false
            }
        }
    }
}

// MARK: - Preview

private func previewContent<Label>(@ViewBuilder _ label: () -> Label) -> some View where Label: View {
    VStack {
        AsyncButton {
            try? await Task.sleep(for: .seconds(3))
        } label: {
            label()
        }
    }
}

#Preview("Text") {
    previewContent {
        Text("Perform action")
    }
}

#Preview("Image") {
    previewContent {
        Image(systemName: "square.and.arrow.up")
    }
}

#Preview("Label") {
    previewContent {
        Label("Export", systemImage: "square.and.arrow.up")
    }
}

#Preview("Bordered style") {
    previewContent {
        Text("Perform action")
    }
    .buttonStyle(.bordered)
}

#Preview("List") {
    List {
        previewContent {
            Text("Perform action")
                .frame(maxWidth: .infinity)
        }
    }
}
