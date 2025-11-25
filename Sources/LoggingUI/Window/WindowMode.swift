// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

#if os(iOS)
    import UIKit
#endif

enum WindowMode {
    static var isSupported: Bool {
        #if os(iOS)
            UIApplication.shared.supportsMultipleScenes
        #elseif os(macOS)
            true
        #else
            false
        #endif
    }
}
