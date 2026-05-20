import Foundation
import BookmarkDomain

public extension BookmarkInterest {
    static let tech = BookmarkInterest(id: 1, name: "테크")
    static let design = BookmarkInterest(id: 2, name: "디자인")
    static let business = BookmarkInterest(id: 3, name: "비즈니스")
    static let culture = BookmarkInterest(id: 4, name: "문화")
}

public extension BookmarkItem {
    static let dailyTech = BookmarkItem(
        brandName: "Daily Bytes",
        brandId: 1,
        articleTitle: "오늘의 테크 한 입",
        articleId: 1001,
        sampleText: "AI가 바꾸는 일상의 풍경. 가장 두드러진 변화는...",
        date: "2026-05-20",
        imageURL: "https://picsum.photos/seed/db/200"
    )

    static let weeklyDesign = BookmarkItem(
        brandName: "Weekly Design",
        brandId: 2,
        articleTitle: "한 주의 디자인 시스템 트렌드",
        articleId: 1002,
        sampleText: "토큰 기반 시스템이 빠르게 표준으로 자리잡고 있다.",
        date: "2026-05-13",
        imageURL: "https://picsum.photos/seed/wd/200"
    )

    static let morningBrew = BookmarkItem(
        brandName: "Morning Brew",
        brandId: 3,
        articleTitle: "오늘 아침의 마켓 뉴스",
        articleId: 1003,
        sampleText: "스타트업 시장은 회복기에 접어들고 있는 것으로...",
        date: "2026-05-19",
        imageURL: "https://picsum.photos/seed/mb/200"
    )

    static let designerNews = BookmarkItem(
        brandName: "Designer News",
        brandId: 4,
        articleTitle: "디자이너가 본 새 OS",
        articleId: 1004,
        sampleText: "새 OS의 디자인 언어가 의미하는 것.",
        date: "2026-04-25",
        imageURL: "https://picsum.photos/seed/dn/200"
    )
}

public enum SampleBookmarkInterests {
    public static let empty: [BookmarkInterest] = []

    public static let mixed: [BookmarkInterest] = [
        .tech,
        .design,
        .business,
        .culture
    ]
}

public enum SampleBookmarkedArticles {
    public static let empty = BookmarkedArticles(totalAmount: 0, bookmarkForMonth: [])

    public static let single = BookmarkedArticles(
        totalAmount: 1,
        bookmarkForMonth: [
            MonthlyBookmark(month: "2026-05", bookmark: [.dailyTech])
        ]
    )

    public static let mixed = BookmarkedArticles(
        totalAmount: 4,
        bookmarkForMonth: [
            MonthlyBookmark(month: "2026-05", bookmark: [.dailyTech, .morningBrew, .weeklyDesign]),
            MonthlyBookmark(month: "2026-04", bookmark: [.designerNews])
        ]
    )

    public static let manyForScrolling: BookmarkedArticles = {
        let items = (1...20).map { index in
            BookmarkItem(
                brandName: "Brand \(index)",
                brandId: index,
                articleTitle: "샘플 북마크 \(index)",
                articleId: 2000 + index,
                sampleText: "샘플 텍스트 \(index)",
                date: "2026-05-\(String(format: "%02d", (index % 28) + 1))",
                imageURL: "https://picsum.photos/seed/bm\(index)/200"
            )
        }
        return BookmarkedArticles(
            totalAmount: items.count,
            bookmarkForMonth: [MonthlyBookmark(month: "2026-05", bookmark: items)]
        )
    }()
}
