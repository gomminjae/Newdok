import Foundation

public protocol FetchExploreBrandDetailUseCase: Sendable {
    func execute(id: String) async throws -> ExploreBrandDetail
}
