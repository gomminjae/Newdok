import Foundation

public protocol SubscribePopupStorable: Sendable {
    var shouldShow: Bool { get }
    func hideForToday()
}
