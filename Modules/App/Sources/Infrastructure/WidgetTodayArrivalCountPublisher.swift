import Foundation
import HomeDomain
import Shared
import WidgetKit

struct WidgetTodayArrivalCountPublisher: TodayArrivalCountPublishing {
    private let storage: TodayArrivalCountWriting

    init(storage: TodayArrivalCountWriting) {
        self.storage = storage
    }

    func publishTodayArrivalCount(_ count: Int) {
        storage.updateTodayArrivalCount(count)
        WidgetCenter.shared.reloadTimelines(ofKind: WidgetKind.todayArrival)
    }
}
