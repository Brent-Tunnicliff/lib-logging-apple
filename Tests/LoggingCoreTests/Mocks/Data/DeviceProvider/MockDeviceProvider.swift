// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import LoggingCore
import Synchronization

final class MockDeviceProvider: DeviceProvider {
    private let deviceMutex = Mutex<Device>(.mock())
    var deviceValue: Device {
        get {
            deviceMutex.withLock { $0 }
        }
        set {
            deviceMutex.withLock { $0 = newValue }
        }
    }

    func currentDevice() async -> Device {
        deviceValue
    }
}
