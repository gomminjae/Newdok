import Foundation
import DetailDomain

public final class MockFetchArticleDetailUseCase: FetchArticleDetailUseCase {
    public var result: Result<DetailArticleDetailResult, Error> = .success(
        DetailArticleDetailResult(
            detail: DetailArticleDetail(
                articleTitle: "테스트 아티클",
                articleId: 1,
                date: "2025-01-01",
                brandId: 1,
                brandName: "테스트 브랜드",
                articleHTML: "<p>test</p>",
                brandImageUrl: "",
                isBookmarked: false
            ),
            articleId: "1"
        )
    )
    public private(set) var executedArticleId: String?

    public init() {}

    public func execute(articleId: String) async throws -> DetailArticleDetailResult {
        executedArticleId = articleId
        return try result.get()
    }
}
