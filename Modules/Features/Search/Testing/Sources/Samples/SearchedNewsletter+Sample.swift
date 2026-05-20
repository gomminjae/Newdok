import Foundation
import SearchDomain

public extension SearchedNewsletter {
    static let dailyBytes = SearchedNewsletter(
        id: "1",
        brandName: "Daily Bytes",
        firstDescription: "매일 아침 받아보는 테크 한 입",
        imageUrl: "https://picsum.photos/seed/db/200"
    )

    static let weeklyDesign = SearchedNewsletter(
        id: "2",
        brandName: "Weekly Design",
        firstDescription: "매주 월요일 디자인 트렌드",
        imageUrl: "https://picsum.photos/seed/wd/200"
    )

    static let morningBrew = SearchedNewsletter(
        id: "3",
        brandName: "Morning Brew",
        firstDescription: "평일 매일 마켓 뉴스",
        imageUrl: "https://picsum.photos/seed/mb/200"
    )

    static let designerNews = SearchedNewsletter(
        id: "4",
        brandName: "Designer News",
        firstDescription: "디자이너를 위한 한 주",
        imageUrl: "https://picsum.photos/seed/dn/200"
    )
}

public enum SampleSearchedNewsletters {
    public static let empty: [SearchedNewsletter] = []

    public static let single: [SearchedNewsletter] = [.dailyBytes]

    public static let mixed: [SearchedNewsletter] = [
        .dailyBytes,
        .weeklyDesign,
        .morningBrew,
        .designerNews
    ]

    public static let manyForScrolling: [SearchedNewsletter] = (1...20).map { index in
        SearchedNewsletter(
            id: "\(index)",
            brandName: "Brand \(index)",
            firstDescription: "샘플 뉴스레터 \(index)",
            imageUrl: "https://picsum.photos/seed/search\(index)/200"
        )
    }
}

public enum SamplePopularKeywords {
    public static let empty = PopularKeywordList(updatedDate: "2026-05-20", keywords: [])

    public static let mixed = PopularKeywordList(
        updatedDate: "2026-05-20",
        keywords: [
            PopularKeyword(rank: 1, keyword: "AI"),
            PopularKeyword(rank: 2, keyword: "디자인"),
            PopularKeyword(rank: 3, keyword: "스타트업"),
            PopularKeyword(rank: 4, keyword: "테크"),
            PopularKeyword(rank: 5, keyword: "마케팅"),
            PopularKeyword(rank: 6, keyword: "비즈니스"),
            PopularKeyword(rank: 7, keyword: "프로덕트"),
            PopularKeyword(rank: 8, keyword: "리더십"),
            PopularKeyword(rank: 9, keyword: "조직문화"),
            PopularKeyword(rank: 10, keyword: "투자")
        ]
    )
}
