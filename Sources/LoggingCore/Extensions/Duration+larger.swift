// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

extension Duration {
    // MARK: - Minutes

    @inlinable
    package static func minutes<T>(_ minutes: T) -> Duration where T: BinaryInteger {
        seconds(minutes * 60)
    }

    package static func minutes(_ minutes: Double) -> Duration {
        seconds(minutes * 60)
    }

    // MARK: - Hours

    @inlinable
    package static func hours<T>(_ hours: T) -> Duration where T: BinaryInteger {
        minutes(hours * 60)
    }

    package static func hours(_ hours: Double) -> Duration {
        minutes(hours * 60)
    }

    // MARK: - Days

    @inlinable
    package static func days<T>(_ days: T) -> Duration where T: BinaryInteger {
        hours(days * 24)
    }

    package static func days(_ days: Double) -> Duration {
        hours(days * 24)
    }
}
