public protocol FetchBookmarkedArticlesUseCase: Sendable {
    func execute(interest: Int?, sortBy: BookmarkSortOption) async throws -> BookmarkedArticles
}
