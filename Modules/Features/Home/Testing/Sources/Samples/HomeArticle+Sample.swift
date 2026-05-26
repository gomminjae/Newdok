import Foundation
import HomeDomain

public extension HomeArticle {
    static let todayDaily = HomeArticle(
        brandName: "Daily Bytes",
        imageUrl: "https://picsum.photos/seed/db/200",
        articleTitle: "오늘의 테크 한 입",
        articleId: 1001,
        status: .unread,
        publishDate: 20260520,
        highlightCount: 3
    )

    static let todayDesign = HomeArticle(
        brandName: "Weekly Design",
        imageUrl: "https://picsum.photos/seed/wd/200",
        articleTitle: "한 주의 디자인 시스템 트렌드",
        articleId: 1002,
        status: .unread,
        publishDate: 20260520,
        highlightCount: 1
    )

    static let todayBrew = HomeArticle(
        brandName: "Morning Brew",
        imageUrl: "https://picsum.photos/seed/mb/200",
        articleTitle: "오늘 아침의 마켓 뉴스",
        articleId: 1003,
        status: .read,
        publishDate: 20260520,
        highlightCount: 0
    )

    static let pastTrends = HomeArticle(
        brandName: "Tech Trends",
        imageUrl: "https://picsum.photos/seed/tt/200",
        articleTitle: "지난주 트렌드 정리",
        articleId: 1004,
        status: .read,
        publishDate: 20260513,
        highlightCount: 2
    )

    static let pastDesigner = HomeArticle(
        brandName: "Designer News",
        imageUrl: "https://picsum.photos/seed/dn/200",
        articleTitle: "디자이너가 본 새 OS",
        articleId: 1005,
        status: .unread,
        publishDate: 20260515,
        highlightCount: 4
    )
}

public enum SampleHomeArticles {
    public static let empty: [HomeArticle] = []

    public static let single: [HomeArticle] = [.todayDaily]

    public static let mixed: [HomeArticle] = [
        .todayDaily,
        .todayDesign,
        .todayBrew,
        .pastDesigner
    ]

    public static let manyForScrolling: [HomeArticle] = (1...20).map { index in
        HomeArticle(
            brandName: "Brand \(index)",
            imageUrl: "https://picsum.photos/seed/article\(index)/200",
            articleTitle: "샘플 아티클 \(index)",
            articleId: 2000 + index,
            status: index % 3 == 0 ? .read : .unread,
            publishDate: 20260520,
            highlightCount: index % 5
        )
    }
}
