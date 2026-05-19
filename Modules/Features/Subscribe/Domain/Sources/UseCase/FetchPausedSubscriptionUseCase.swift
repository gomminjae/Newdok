import Foundation

public protocol FetchPausedSubscriptionUseCase: Sendable {
    func execute() async throws -> [SubscribeNewsletter]
}
