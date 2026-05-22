import Foundation

public protocol FetchPopularKeywordsUseCase: Sendable {
    func execute() async throws -> PopularKeywordList
}
