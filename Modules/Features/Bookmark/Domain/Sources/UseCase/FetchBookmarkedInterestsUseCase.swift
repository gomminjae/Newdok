import Foundation

public protocol FetchBookmarkedInterestsUseCase: Sendable {
    func execute() async throws -> [BookmarkInterest]
}
