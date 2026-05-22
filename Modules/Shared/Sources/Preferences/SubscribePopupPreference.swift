import Foundation

public final class SubscribePopupPreference: SubscribePopupStorable, @unchecked Sendable {
    public static let shared = SubscribePopupPreference()

    private enum Key {
        static let hideDate = "hideSubscribeStatePopupDate"
    }

    private init() {}

    private var hideDate: Date? {
        get { UserDefaults.standard.object(forKey: Key.hideDate) as? Date }
        set {
            if let date = newValue {
                UserDefaults.standard.set(date, forKey: Key.hideDate)
            } else {
                UserDefaults.standard.removeObject(forKey: Key.hideDate)
            }
        }
    }

    public var shouldShow: Bool {
        guard let hideDate else { return true }
        return !Calendar.current.isDate(hideDate, inSameDayAs: Date())
    }

    public func hideForToday() {
        hideDate = Date()
    }
}
