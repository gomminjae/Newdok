import Foundation

public protocol FetchSubscriptionCountUseCase: Sendable {
    func execute() async throws -> Int
}
