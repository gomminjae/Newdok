import Foundation

public protocol FetchGuestExploreBrandDetailUseCase: Sendable {
    func execute(id: String) async throws -> ExploreBrandDetail
}
