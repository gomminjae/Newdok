import Foundation

public protocol TodayArrivalCountPublishing: Sendable {
    func publishTodayArrivalCount(_ count: Int)
}
