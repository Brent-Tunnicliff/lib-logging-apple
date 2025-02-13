// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

public import Foundation

// MARK: - Device

public struct Device {
    public let identifierForVendor: UUID?
    public let model: String?
    public let systemName: String?
    public let systemVersion: String?
    public let userInterfaceIdiom: UserInterfaceIdiom
}

extension Device: Codable {}
extension Device: Equatable {}
extension Device: Sendable {}

#if DEBUG
    extension Device {
        public static func mock(
            identifierForVendor: UUID? = UUID(),
            model: String? = "iPhone",
            systemName: String? = "iOS",
            systemVersion: String? = "18.3",
            userInterfaceIdiom: UserInterfaceIdiom = .phone
        ) -> Device {
            Device(
                identifierForVendor: identifierForVendor,
                model: model,
                systemName: systemName,
                systemVersion: systemVersion,
                userInterfaceIdiom: userInterfaceIdiom
            )
        }
    }
#endif

// MARK: - UserInterfaceIdiom

extension Device {
    public struct UserInterfaceIdiom {
        let rawValue: RawValue

        fileprivate init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
    }
}

extension Device.UserInterfaceIdiom: Codable {}
extension Device.UserInterfaceIdiom: Equatable {}
extension Device.UserInterfaceIdiom: Sendable {}

extension Device.UserInterfaceIdiom: CustomStringConvertible {
    public var description: String {
        "\(rawValue)"
    }
}

extension Device.UserInterfaceIdiom {
    public static let carPlay = Device.UserInterfaceIdiom(rawValue: .carPlay)
    public static let mac = Device.UserInterfaceIdiom(rawValue: .mac)
    public static let pad = Device.UserInterfaceIdiom(rawValue: .pad)
    public static let phone = Device.UserInterfaceIdiom(rawValue: .phone)
    public static let tv = Device.UserInterfaceIdiom(rawValue: .tv)
    public static let unspecified = Device.UserInterfaceIdiom(rawValue: .unspecified)
    public static let vision = Device.UserInterfaceIdiom(rawValue: .vision)
    public static let watch = Device.UserInterfaceIdiom(rawValue: .watch)
}

extension Device.UserInterfaceIdiom: CaseIterable {
    public static let allCases: [Device.UserInterfaceIdiom] = [
        // Manually defining each one so we can test that they all raw values have a defined constant.
        carPlay,
        mac,
        pad,
        phone,
        tv,
        unspecified,
        vision,
        watch
    ]
}

// MARK: - RawValue

extension Device.UserInterfaceIdiom {
    // Keeping the enum internal to minimise the risk of breaking changes if this changes.
    enum RawValue: String {
        case carPlay
        case mac
        case pad
        case phone
        case tv
        case unspecified
        case vision
        case watch
    }
}

extension Device.UserInterfaceIdiom.RawValue: Codable {}
extension Device.UserInterfaceIdiom.RawValue: CaseIterable {}

// MARK: - Constants

// The order of these are important as some platforms can contain multiple.

#if canImport(WatchKit)

    // MARK: WatchKit

    import WatchKit

    extension Device {
        @MainActor
        public static let current: Device = {
            let device = WKInterfaceDevice.current()
            return Device(
                identifierForVendor: device.identifierForVendor,
                model: device.model,
                systemName: device.systemName,
                systemVersion: device.systemVersion,
                userInterfaceIdiom: .watch
            )
        }()
    }

#elseif canImport(UIKit)

    // MARK: UIKit

    import UIKit

    extension UIUserInterfaceIdiom {
        var asUserInterfaceIdiom: Device.UserInterfaceIdiom {
            Device.UserInterfaceIdiom(rawValue: asRawValue)
        }

        private var asRawValue: Device.UserInterfaceIdiom.RawValue {
            switch self {
            case .carPlay: .carPlay
            case .mac: .mac
            case .pad: .pad
            case .phone: .phone
            case .tv: .tv
            case .unspecified: .unspecified
            case .vision: .vision
            @unknown default: .unspecified
            }
        }
    }

    extension Device {
        @MainActor
        public static let current: Device = {
            let device = UIDevice.current
            return Device(
                identifierForVendor: device.identifierForVendor,
                model: device.model,
                systemName: device.systemName,
                systemVersion: device.systemVersion,
                userInterfaceIdiom: device.userInterfaceIdiom.asUserInterfaceIdiom
            )
        }()
    }

#elseif canImport(IOKit)

    // MARK: MacOS

    import IOKit

    extension Device {
        @MainActor
        public static let current: Device = {
            let service = IOServiceGetMatchingService(
                kIOMainPortDefault,
                IOServiceMatching("IOPlatformExpertDevice")
            )

            defer {
                IOObjectRelease(service)
            }

            guard service != 0 else {
                // We are unable to use service to get the needed values.
                return Device(
                    identifierForVendor: nil,
                    model: nil,
                    systemName: nil,
                    systemVersion: nil,
                    userInterfaceIdiom: .mac
                )
            }

            let hardwareDeviceId = IORegistryEntryCreateCFProperty(
                service,
                kIOPlatformUUIDKey as CFString,
                kCFAllocatorDefault,
                0
            )?.takeRetainedValue() as? String

            let modelData = IORegistryEntryCreateCFProperty(
                service,
                "model" as CFString,
                kCFAllocatorDefault,
                0
            ).takeRetainedValue() as? Data
            let model: String? = if let modelData {
                String(data: modelData, encoding: .utf8)?.trimmingCharacters(in: .controlCharacters)
            } else {
                nil
            }

            return Device(
                identifierForVendor: (hardwareDeviceId).map(UUID.init(uuidString:)) ?? nil,
                model: model,
                systemName: nil,
                systemVersion: ProcessInfo.processInfo.operatingSystemVersion.description,
                userInterfaceIdiom: .mac
            )
        }()
    }

    private extension OperatingSystemVersion {
        var description: String {
            "\(majorVersion).\(minorVersion).\(patchVersion)"
        }
    }

#endif
