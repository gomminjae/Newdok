import Foundation

public extension Notification.Name {
    static let didReceiveUnauthorized = Notification.Name("didReceiveUnauthorized")
    static let didLoginSuccess = Notification.Name("didLoginSuccess")
    static let showToast = Notification.Name("showToast")
    static let articleStatusChanged = Notification.Name("articleStatusChanged")
}

public enum AuthEvent {
    public static func notifyUnauthorized() {
        Task { @MainActor in
            NotificationCenter.default.post(name: .didReceiveUnauthorized, object: nil)
        }
    }
}
