import Foundation

public protocol OnboardingStorable: Sendable {
    var hasCompletedOnboarding: Bool { get }
    func markCompleted()
}
