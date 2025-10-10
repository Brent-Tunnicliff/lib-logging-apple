// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import LoggingCore
import SwiftData
import SwiftUI

struct LogItemView: View {
    @Environment(\.layoutDirection) private var layoutDirection
    @State private var isExpanded: Bool

    /// String to be injected if there is no real value to use.
    private let unknown = "???"

    private let log: LogEntity

    init(log: LogEntity, initialExpandedValue: Bool = false) {
        self.log = log
        self._isExpanded = State(initialValue: initialExpandedValue)
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 6) {
                logLevelLabel
                messageLabel
                errorLabel
                packageNameLabel
                tagLabel
                timestampLabel
                expandedView
            }

            Spacer()

            chevronImage
        }
        .lineLimit(isExpanded ? nil : 3)
        .listRowBackground(
            backgroundColor
                .opacity(0.2)
        )
        .padding(.bottom, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            isExpanded.toggle()
        }
    }

    private var backgroundColor: Color {
        switch log.level {
        case .critical: .red
        case .debug, .info: .clear
        case .error: .orange
        }
    }

    @ViewBuilder
    private var chevronImage: some View {
        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
            .contentTransition(.symbolEffect(.replace, options: .speed(3)))
    }

    @ViewBuilder
    private var expandedView: some View {
        if isExpanded {
            Divider()

            VStack(alignment: .leading) {
                logIdLabel
                deviceIdentifierForVendorLabel
                deviceModelLabel
                deviceSystemLabel
                deviceUserInterfaceIdiomLabel
            }
            .padding(.leading, 8)
        }
    }

    // MARK: - Labels

    @ViewBuilder
    private var deviceIdentifierForVendorLabel: some View {
        Text(.identifierForVendor(log.device.identifierForVendor?.uuidString ?? unknown))
            .font(.caption2)
    }

    @ViewBuilder
    private var deviceModelLabel: some View {
        Text(.deviceModel(log.device.model ?? unknown))
            .font(.caption2)
    }

    @ViewBuilder
    private var deviceSystemLabel: some View {
        Group {
            switch (log.device.systemName, log.device.systemVersion) {
            case (nil, nil):
                // Unable to determine either.
                Text(.deviceSystemUnknown)
            case let (nil, systemVersion):
                // Only show the system version.
                Text(verbatim: systemVersion ?? unknown)
            case let (systemName, nil):
                // Only show the system name.
                Text(verbatim: systemName ?? unknown)
            case let (systemName, systemVersion):
                // Show both system name and version, e.g. 'iOS 18.5'.
                // Seems even right-to-left languages show this combo in this order,
                // I checked the iPhone system settings and how they show it when in Arabic.
                // So should be fine.
                Text(verbatim: "\(systemName ?? unknown) \(systemVersion ?? unknown)")
            }
        }
        .font(.caption2)
    }

    @ViewBuilder
    private var deviceUserInterfaceIdiomLabel: some View {
        Text(.deviceUserInterfaceIdiomLabel(log.device.userInterfaceIdiom.label ?? unknown))
            .font(.caption2)
    }

    @ViewBuilder
    private var errorLabel: some View {
        if let error = log.error {
            Text(.logErrorTitle(error.type, error.message, error.localizedDescription))
        }
    }

    @ViewBuilder
    private var logIdLabel: some View {
        Text(.logId(log.id.uuidString))
            .font(.caption2)
    }

    @ViewBuilder
    private var logLevelLabel: some View {
        log.level.label
            .font(.footnote)
    }

    @ViewBuilder
    private var messageLabel: some View {
        // No current plans to have our log messages localized as that will be difficult to maintain,
        // so will just be what ever the message the developer wrote.
        // Unfortunate if any non-english speakers use this.
        Text(verbatim: log.message)
    }

    @ViewBuilder
    private var packageNameLabel: some View {
        Text(verbatim: log.packageName)
            .font(.caption2)
    }

    @ViewBuilder
    private var tagLabel: some View {
        Text(
            verbatim: layoutDirectionBasedText(
                inputs: [
                    log.tag.file,
                    log.tag.function,
                    log.tag.line.description,
                ],
                separator: ":"
            )
        )
        .font(.caption2)
    }

    @ViewBuilder
    private var timestampLabel: some View {
        Text(log.timestampCreated, format: Date.FormatStyle(date: .abbreviated, time: .complete))
            .font(.caption2)
    }

    private func layoutDirectionBasedText(inputs: [String], separator: String) -> String {
        let layoutDirectionBasedInputs = layoutDirection == .leftToRight ? inputs : inputs.reversed()
        return layoutDirectionBasedInputs.joined(separator: separator)
    }
}

extension LogEntity.UserInterfaceIdiom {
    fileprivate var label: String? {
        switch self {
        case .carPlay: "CarPlay"
        case .mac: "Mac"
        case .pad: "iPad"
        case .phone: "iPhone"
        case .tv: "TV"
        case .unspecified: nil
        case .vision: "Vision"
        case .watch: "Watch"
        }
    }
}

#Preview {
    let longMessage = """
        This message is very long, so that we can test out wrapping and truncating logic. \
        Blah, blah, blah. How about this weather huh? It has been raining lots tonight. \
        Luckily it was not raining while I was outside.
        """
    List {
        Section("Expanded") {
            LogItemView(
                log: .mock(),
                initialExpandedValue: true
            )
        }

        Section("Log levels") {
            ForEach(LogEntity.LogLevel.allCases, id: \.self) {
                LogItemView(log: .mock(level: $0))
            }
        }

        Section("Truncating") {
            LogItemView(log: .mock(message: longMessage))

            LogItemView(log: .mock(error: .mock(message: longMessage)))

            LogItemView(
                log: .mock(
                    message: longMessage,
                    error: .mock(message: longMessage)
                )
            )
        }

        Section("User Interface Idiom") {
            ForEach(LogEntity.UserInterfaceIdiom.allCases, id: \.self) {
                LogItemView(
                    log: .mock(device: .mock(userInterfaceIdiom: $0)),
                    initialExpandedValue: true
                )
            }
        }
    }
}
