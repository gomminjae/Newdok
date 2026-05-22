import Foundation

public final class OnboardingStorage: OnboardingStorable, @unchecked Sendable {
    public static let shared = OnboardingStorage()

    private enum Key {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
    }

    private init() {}

    public var hasCompletedOnboarding: Bool {
        UserDefaults.standard.bool(forKey: Key.hasCompletedOnboarding)
    }

    public func markCompleted() {
        UserDefaults.standard.set(true, forKey: Key.hasCompletedOnboarding)
    }
}
