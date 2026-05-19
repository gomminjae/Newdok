import Foundation

public protocol FetchReceivedArticleCountUseCase: Sendable {
    func execute() async throws -> Int
}
