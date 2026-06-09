import Foundation
import DetailDomain

public extension DetailInterest {
    static let tech = DetailInterest(id: 1, name: "테크")
    static let design = DetailInterest(id: 2, name: "디자인")
    static let business = DetailInterest(id: 3, name: "비즈니스")
}

public extension DetailBrandArticle {
    static let recent = DetailBrandArticle(
        id: 1001,
        title: "가장 최신 발행 아티클",
        date: "2026-05-20"
    )

    static let lastWeek = DetailBrandArticle(
        id: 1002,
        title: "지난주 발행 아티클",
        date: "2026-05-13"
    )

    static let twoWeeksAgo = DetailBrandArticle(
        id: 1003,
        title: "2주 전 발행 아티클",
        date: "2026-05-06"
    )
}

public extension DetailBrandDetail {
    static let dailyBytes = DetailBrandDetail(
        brandId: 1,
        brandName: "Daily Bytes",
        detailDescription: "매일 아침 5분, 가장 빠른 테크 한 입.",
        publicationCycle: "매일",
        subscribeUrl: "https://example.com/subscribe/1",
        imageUrl: "https://picsum.photos/seed/db/200",
        interests: [.tech, .business],
        brandArticleList: [.recent, .lastWeek, .twoWeeksAgo],
        subscriptionStatus: .confirmed,
        subscribeCheck: true
    )

    static let weeklyDesign = DetailBrandDetail(
        brandId: 2,
        brandName: "Weekly Design",
        detailDescription: "디자이너를 위한 한 주의 정수.",
        publicationCycle: "매주 월요일",
        subscribeUrl: "https://example.com/subscribe/2",
        imageUrl: "https://picsum.photos/seed/wd/200",
        interests: [.design],
        brandArticleList: [.recent, .lastWeek],
        subscriptionStatus: .initial,
        subscribeCheck: false
    )
}

public extension DetailArticleDetail {
    static let sample = DetailArticleDetail(
        articleTitle: "샘플 아티클: AI가 바꾸는 일상",
        articleId: 1001,
        date: "2026-05-20",
        brandId: 1,
        brandName: "Daily Bytes",
        articleHTML: """
        <h1>AI가 바꾸는 일상</h1>
        <p>샘플 본문입니다. 실제 아티클 컨텐츠가 들어가는 자리입니다.</p>
        <p>두 번째 단락입니다. 본문 폰트 크기 조절 등을 확인할 수 있습니다.</p>
        """,
        brandImageUrl: "https://picsum.photos/seed/db/200",
        isBookmarked: false
    )

    static let bookmarked = DetailArticleDetail(
        articleTitle: "북마크된 샘플 아티클",
        articleId: 1002,
        date: "2026-05-13",
        brandId: 2,
        brandName: "Weekly Design",
        articleHTML: "<h1>북마크된 아티클</h1><p>이 아티클은 북마크 상태입니다.</p>",
        brandImageUrl: "https://picsum.photos/seed/wd/200",
        isBookmarked: true
    )
}

public enum SampleDetailBrands {
    public static let dailyBytes: DetailBrandDetail = .dailyBytes
    public static let weeklyDesign: DetailBrandDetail = .weeklyDesign
}

public enum SampleDetailArticles {
    public static let unread: DetailArticleDetail = .sample
    public static let bookmarked: DetailArticleDetail = .bookmarked
}

public enum SampleDetailHighlights {
    public static let empty: [DetailHighlight] = []

    public static let mixed: [DetailHighlight] = [
        DetailHighlight(
            id: UUID(),
            articleId: "1001",
            articleTitle: "샘플 아티클: AI가 바꾸는 일상",
            brandName: "Daily Bytes",
            selectedText: "AI가 바꾸는 일상",
            style: .yellow,
            textOffset: 0,
            createdAt: Date()
        ),
        DetailHighlight(
            id: UUID(),
            articleId: "1001",
            articleTitle: "샘플 아티클: AI가 바꾸는 일상",
            brandName: "Daily Bytes",
            selectedText: "샘플 본문",
            style: .green,
            textOffset: 30,
            createdAt: Date()
        )
    ]
}
