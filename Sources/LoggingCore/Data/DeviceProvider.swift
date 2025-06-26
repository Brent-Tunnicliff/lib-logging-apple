// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

package protocol DeviceProvider: Sendable {
    func current() async -> Device
}

package final class DefaultDeviceProvider: DeviceProvider {
    package func current() async -> Device {
        await Device.current
    }
}
