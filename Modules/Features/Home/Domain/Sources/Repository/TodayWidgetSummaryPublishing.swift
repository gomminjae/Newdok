import Foundation

public protocol TodayWidgetSummaryPublishing: Sendable {
    func publishTodaySummary(
        totalCount: Int,
        unreadCount: Int,
        date: Date
    )

    func clearTodaySummary()
}
