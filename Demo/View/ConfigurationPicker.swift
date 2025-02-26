// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import SwiftUI

/// Common configuration picker.
///
/// Displays as a `Button` and `Sheet` on WatchOS, but as a `SegmentedPickerStyle` on others.
struct ConfigurationPicker<Option: Hashable, Label: View>: View {
    @Binding private var selectedOption: Option

    private let label: Label
    private let options: [Option]
    private let textProvider: (Option) -> String

    init(
        options: [Option],
        selectedLogLevel: Binding<Option>,
        textProvider: @escaping (Option) -> String,
        @ViewBuilder label: () -> Label
    ) {
        self.options = options
        self._selectedOption = selectedLogLevel
        self.textProvider = textProvider
        self.label = label()
    }

    var body: some View {
        #if os(watchOS)
            watchOSPicker
        #else
            defaultPicker
        #endif
    }

    private var commonLogLevelPicker: some View {
        Picker(selection: $selectedOption) {
            ForEach(options, id: \.self) { option in
                Text(textProvider(option))
                    .tag(option)
            }
        } label: {
            label
        }
    }

    #if os(watchOS)
        @State private var showPickerSheet = false

        // Segmented picker is not supported on WatchOS,
        // so instead wrapping this to use a sheet.
        private var watchOSPicker: some View {
            Button {
                showPickerSheet = true
            } label: {
                label
            }
            .sheet(isPresented: $showPickerSheet) {
                commonLogLevelPicker
            }
        }
    #else
        private var defaultPicker: some View {
            commonLogLevelPicker
                .pickerStyle(.segmented)
        }
    #endif
}
