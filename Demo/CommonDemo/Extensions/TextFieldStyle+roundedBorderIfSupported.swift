// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import SwiftUI

/// Applies `roundedBorder` text field style if supported.
///
/// The purpose of this is to get around `#if` compiler conditions in the views.
struct RoundedBorderIfSupportedTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<_Label>) -> some View {
        #if os(watchOS) || os(tvOS)
            configuration
        #else
            configuration.textFieldStyle(.roundedBorder)
        #endif
    }
}

extension TextFieldStyle where Self == RoundedBorderIfSupportedTextFieldStyle {
    static var roundedBorderIfSupported: RoundedBorderIfSupportedTextFieldStyle {
        RoundedBorderIfSupportedTextFieldStyle()
    }
}
