public protocol FetchBookmarkedArticlesUseCase: Sendable {
    func execute(interest: String?, sortBy: BookmarkSortOption) async throws -> BookmarkedArticles
}
