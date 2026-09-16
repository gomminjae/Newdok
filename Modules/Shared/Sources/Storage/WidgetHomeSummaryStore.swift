import Foundation

public enum WidgetKind {
    public static let homeSummary = "HomeSummaryWidget"
}

public struct WidgetHomeSummary: Codable, Equatable, Sendable {
    public let date: Date
    public let todayTotalCount: Int
    public let unreadCount: Int

    public init(date: Date, todayTotalCount: Int, unreadCount: Int) {
        self.date = date
        self.todayTotalCount = todayTotalCount
        self.unreadCount = unreadCount
    }

    public static func empty(for date: Date = Date()) -> Self {
        Self(date: date, todayTotalCount: 0, unreadCount: 0)
    }
}

public struct AppGroupWidgetHomeSummaryStore: Sendable {
    private static let storageKey = "widget_home_summary"

    private let appGroupID: String

    public init?(appGroupID: String) {
        let trimmedID = appGroupID.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedID.isEmpty, !trimmedID.hasPrefix("$(") else { return nil }
        self.appGroupID = trimmedID
    }

    public func readWidgetHomeSummary() -> WidgetHomeSummary? {
        guard let data = UserDefaults(suiteName: appGroupID)?.data(forKey: Self.storageKey) else {
            return nil
        }
        return try? JSONDecoder().decode(WidgetHomeSummary.self, from: data)
    }

    public func writeWidgetHomeSummary(_ summary: WidgetHomeSummary) {
        guard let data = try? JSONEncoder().encode(summary) else { return }
        UserDefaults(suiteName: appGroupID)?.set(data, forKey: Self.storageKey)
    }

    public func clearWidgetHomeSummary() {
        UserDefaults(suiteName: appGroupID)?.removeObject(forKey: Self.storageKey)
    }
}
