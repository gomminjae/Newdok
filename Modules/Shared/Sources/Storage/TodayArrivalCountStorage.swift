import Foundation

public enum WidgetKind {
    public static let todayArrival = "TodayArrivalWidget"
}

public protocol TodayArrivalCountReading: Sendable {
    var todayArrivalCount: Int { get }
}

public protocol TodayArrivalCountWriting: Sendable {
    func updateTodayArrivalCount(_ count: Int)
}

public struct AppGroupTodayArrivalCountStorage: TodayArrivalCountReading, TodayArrivalCountWriting, @unchecked Sendable {
    private static let countKey = "today_arrival_count"

    private let defaults: UserDefaults

    public init?(appGroupID: String) {
        guard let defaults = UserDefaults(suiteName: appGroupID) else { return nil }
        self.defaults = defaults
    }

    public var todayArrivalCount: Int {
        defaults.integer(forKey: Self.countKey)
    }

    public func updateTodayArrivalCount(_ count: Int) {
        defaults.set(count, forKey: Self.countKey)
    }
}
