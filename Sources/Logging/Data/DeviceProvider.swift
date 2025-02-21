// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

protocol DeviceProvider: Sendable {
    func current() async -> Device
}

final class DefaultDeviceProvider: DeviceProvider {
    func current() async -> Device {
        await Device.current
    }
}
