import Foundation
import ExploreDomain

public final class MockFetchExploreBrandDetailUseCase: FetchExploreBrandDetailUseCase {
    public var result: Result<ExploreBrandDetail, Error> = .success(
        ExploreBrandDetail(brandId: 1, brandName: "테스트", detailDescription: nil, publicationCycle: "매일", subscribeUrl: "", imageUrl: nil, interests: [], brandArticleList: [], isSubscribed: nil, subscribeCheck: false)
    )
    public private(set) var executedId: String?

    public init() {}

    public func execute(id: String) async throws -> ExploreBrandDetail {
        executedId = id
        return try result.get()
    }
}
