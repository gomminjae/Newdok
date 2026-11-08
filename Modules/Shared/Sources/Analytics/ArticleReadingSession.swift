import Foundation

/// Only foreground, visible, successfully rendered intervals contribute to the threshold.
public struct ArticleReadingSession: Sendable {
    public static let threshold: Duration = .seconds(30)
    private var accumulated: Duration = .zero
    private var startedAt: ContinuousClock.Instant?
    public private(set) var hasQualified = false

    public init() {}

    public mutating func setActive(_ active: Bool, at instant: ContinuousClock.Instant = .now) {
        if !active, let start = startedAt {
            accumulated += max(.zero, start.duration(to: instant))
            startedAt = nil
        } else if active, startedAt == nil, !hasQualified {
            startedAt = instant
        }
    }

    public func remaining(at instant: ContinuousClock.Instant = .now) -> Duration {
        max(.zero, Self.threshold - elapsed(at: instant))
    }

    public mutating func qualify(at instant: ContinuousClock.Instant = .now) -> Int? {
        guard !hasQualified, startedAt != nil else { return nil }
        let elapsed = elapsed(at: instant)
        guard elapsed >= Self.threshold else { return nil }
        let components = elapsed.components
        let (seconds, overflow) = components.seconds.multipliedReportingOverflow(by: 1_000)
        let (milliseconds, additionOverflow) = seconds.addingReportingOverflow(components.attoseconds / 1_000_000_000_000_000)
        guard !overflow, !additionOverflow, let value = Int(exactly: milliseconds) else { return nil }
        hasQualified = true
        return value
    }

    private func elapsed(at instant: ContinuousClock.Instant) -> Duration {
        accumulated + (startedAt.map { max(.zero, $0.duration(to: instant)) } ?? .zero)
    }
}
