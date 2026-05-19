import Foundation
import Shared

public protocol FetchPopularKeywordsUseCase: Sendable {
    func execute() async throws -> PopularKeywordList
}
