import Foundation
import HomeDomain
import Shared
import WidgetKit

struct WidgetHomeSummaryPublisher: TodayWidgetSummaryPublishing {
    private let store: AppGroupWidgetHomeSummaryStore

    init(store: AppGroupWidgetHomeSummaryStore) {
        self.store = store
    }

    func publishTodaySummary(
        totalCount: Int,
        unreadCount: Int,
        date: Date
    ) {
        store.writeWidgetHomeSummary(
            WidgetHomeSummary(
                date: date,
                todayTotalCount: totalCount,
                unreadCount: unreadCount
            )
        )
        WidgetCenter.shared.reloadTimelines(ofKind: WidgetKind.homeSummary)
    }

    func clearTodaySummary() {
        store.clearWidgetHomeSummary()
        WidgetCenter.shared.reloadTimelines(ofKind: WidgetKind.homeSummary)
    }
}
