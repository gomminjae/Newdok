import Foundation

public protocol ResumeSubscriptionUseCase: Sendable {
    func execute(newsletterId: String) async throws
}
