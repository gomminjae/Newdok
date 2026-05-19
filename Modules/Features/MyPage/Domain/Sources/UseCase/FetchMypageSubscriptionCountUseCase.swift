import Foundation

public protocol FetchMypageSubscriptionCountUseCase: Sendable {
    func execute() async throws -> Int
}
