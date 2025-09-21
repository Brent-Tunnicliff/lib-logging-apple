// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

package protocol DeviceProvider: Sendable {
    func currentDevice() async -> Device
}

package final class DefaultDeviceProvider: DeviceProvider {
    package func currentDevice() async -> Device {
        await Device.current
    }
}
