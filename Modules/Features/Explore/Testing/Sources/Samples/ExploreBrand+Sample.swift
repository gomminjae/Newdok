import Foundation
import ExploreDomain

public extension ExploreInterest {
    static let tech = ExploreInterest(id: 1, name: "테크")
    static let design = ExploreInterest(id: 2, name: "디자인")
    static let business = ExploreInterest(id: 3, name: "비즈니스")
    static let culture = ExploreInterest(id: 4, name: "문화")
}

public extension ExploreBrand {
    static let dailyBytes = ExploreBrand(
        brandId: 1,
        brandName: "Daily Bytes",
        imageUrl: "https://picsum.photos/seed/db/200",
        interests: [.tech, .business],
        isSubscribed: nil,
        shortDescription: "매일 아침 받아보는 테크 한 입",
        subscriptionCount: 12345
    )

    static let weeklyDesign = ExploreBrand(
        brandId: 2,
        brandName: "Weekly Design",
        imageUrl: "https://picsum.photos/seed/wd/200",
        interests: [.design, .culture],
        isSubscribed: "Y",
        shortDescription: "매주 월요일 디자인 트렌드",
        subscriptionCount: 4567
    )

    static let morningBrew = ExploreBrand(
        brandId: 3,
        brandName: "Morning Brew",
        imageUrl: "https://picsum.photos/seed/mb/200",
        interests: [.business],
        isSubscribed: nil,
        shortDescription: "평일 매일 마켓 뉴스",
        subscriptionCount: 9876
    )

    static let designerNews = ExploreBrand(
        brandId: 4,
        brandName: "Designer News",
        imageUrl: "https://picsum.photos/seed/dn/200",
        interests: [.design],
        isSubscribed: nil,
        shortDescription: "디자이너를 위한 한 주",
        subscriptionCount: 2345
    )
}

public extension ExploreNewsletterDetail {
    static let dailyBytesDetail = ExploreNewsletterDetail(
        id: 1,
        brandName: "Daily Bytes",
        firstDescription: "매일 아침 받아보는 테크 한 입",
        secondDescription: "5분이면 충분한 IT 트렌드 요약",
        publicationCycle: "매일",
        subscribeUrl: "https://example.com/subscribe/1",
        imageUrl: "https://picsum.photos/seed/db/200",
        createdAt: "2024-01-01",
        updatedAt: "2026-05-20",
        industries: [],
        interests: [.tech, .business]
    )

    static let weeklyDesignDetail = ExploreNewsletterDetail(
        id: 2,
        brandName: "Weekly Design",
        firstDescription: "매주 월요일 디자인 트렌드",
        secondDescription: "엄선된 디자인 시스템 사례",
        publicationCycle: "매주 월요일",
        subscribeUrl: "https://example.com/subscribe/2",
        imageUrl: "https://picsum.photos/seed/wd/200",
        createdAt: "2024-01-01",
        updatedAt: "2026-05-20",
        industries: [],
        interests: [.design, .culture]
    )

    static let morningBrewDetail = ExploreNewsletterDetail(
        id: 3,
        brandName: "Morning Brew",
        firstDescription: "평일 매일 마켓 뉴스",
        secondDescription: "스타트업과 마켓의 모든 것",
        publicationCycle: "평일 매일",
        subscribeUrl: "https://example.com/subscribe/3",
        imageUrl: "https://picsum.photos/seed/mb/200",
        createdAt: "2024-01-01",
        updatedAt: "2026-05-20",
        industries: [],
        interests: [.business]
    )
}

public enum SampleExploreBrands {
    public static let empty: [ExploreBrand] = []

    public static let single: [ExploreBrand] = [.dailyBytes]

    public static let mixed: [ExploreBrand] = [
        .dailyBytes,
        .weeklyDesign,
        .morningBrew,
        .designerNews
    ]

    public static let manyForScrolling: [ExploreBrand] = (1...20).map { index in
        ExploreBrand(
            brandId: index,
            brandName: "Brand \(index)",
            imageUrl: "https://picsum.photos/seed/brand\(index)/200",
            interests: [.tech],
            isSubscribed: index % 3 == 0 ? "Y" : nil,
            shortDescription: "샘플 브랜드 \(index)",
            subscriptionCount: index * 123
        )
    }
}

public enum SampleExploreRecommendations {
    public static let empty = ExploreRecommendedNewsletter(union: [], intersection: [])

    public static let mixed = ExploreRecommendedNewsletter(
        union: [
            .dailyBytesDetail,
            .weeklyDesignDetail,
            .morningBrewDetail
        ],
        intersection: [
            .dailyBytesDetail,
            .weeklyDesignDetail
        ]
    )
}
