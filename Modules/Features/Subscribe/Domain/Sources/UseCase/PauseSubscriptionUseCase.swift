import Foundation

public protocol PauseSubscriptionUseCase: Sendable {
    func execute(newsletterId: String) async throws
}
