import Foundation
import DetailDomain

public final class MockDetailBrandRepository: DetailBrandRepository, @unchecked Sendable {
    public var brandResult: Result<DetailBrandDetail, Error>
    public var guestBrandResult: Result<DetailBrandDetail, Error>
    public var pauseResult: Result<Void, Error> = .success(())
    public var resumeResult: Result<Void, Error> = .success(())

    public private(set) var fetchBrandCallCount = 0
    public private(set) var fetchGuestBrandCallCount = 0
    public private(set) var pausedNewsletterId: String?
    public private(set) var resumedNewsletterId: String?

    public init(
        brandResult: Result<DetailBrandDetail, Error> = .success(
            DetailBrandDetail(
                brandId: 1,
                brandName: "테스트 브랜드",
                detailDescription: nil,
                publicationCycle: "매일",
                subscribeUrl: "",
                imageUrl: nil,
                interests: [],
                brandArticleList: [],
                isSubscribed: nil,
                subscribeCheck: false
            )
        ),
        guestBrandResult: Result<DetailBrandDetail, Error> = .success(
            DetailBrandDetail(
                brandId: 1,
                brandName: "테스트 브랜드",
                detailDescription: nil,
                publicationCycle: "매일",
                subscribeUrl: "",
                imageUrl: nil,
                interests: [],
                brandArticleList: [],
                isSubscribed: nil,
                subscribeCheck: false
            )
        )
    ) {
        self.brandResult = brandResult
        self.guestBrandResult = guestBrandResult
    }

    public func fetchNewsletterBrand(id: String) async throws -> DetailBrandDetail {
        fetchBrandCallCount += 1
        return try brandResult.get()
    }

    public func fetchGuestNewsletterBrand(id: String) async throws -> DetailBrandDetail {
        fetchGuestBrandCallCount += 1
        return try guestBrandResult.get()
    }

    public func pauseSubscription(newsletterId: String) async throws {
        pausedNewsletterId = newsletterId
        try pauseResult.get()
    }

    public func resumeSubscription(newsletterId: String) async throws {
        resumedNewsletterId = newsletterId
        try resumeResult.get()
    }
}
