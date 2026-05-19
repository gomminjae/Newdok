import Foundation

public protocol FetchActiveSubscriptionUseCase: Sendable {
    func execute() async throws -> [SubscribeNewsletter]
}
