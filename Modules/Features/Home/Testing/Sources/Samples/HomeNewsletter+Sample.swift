import Foundation
import HomeDomain

public extension HomeNewsletter {
    static let dailyBytes = HomeNewsletter(
        id: 1,
        brandName: "Daily Bytes",
        imageUrl: "https://picsum.photos/seed/db/200",
        publicationCycle: "매일"
    )

    static let weeklyDesign = HomeNewsletter(
        id: 2,
        brandName: "Weekly Design",
        imageUrl: "https://picsum.photos/seed/wd/200",
        publicationCycle: "매주 월요일"
    )

    static let morningBrew = HomeNewsletter(
        id: 3,
        brandName: "Morning Brew",
        imageUrl: "https://picsum.photos/seed/mb/200",
        publicationCycle: "평일 매일"
    )

    static let designerNews = HomeNewsletter(
        id: 4,
        brandName: "Designer News",
        imageUrl: "https://picsum.photos/seed/dn/200",
        publicationCycle: "매주 수요일"
    )
}

public enum SampleHomeNewsletters {
    public static let empty: [HomeNewsletter] = []

    public static let single: [HomeNewsletter] = [.dailyBytes]

    public static let mixed: [HomeNewsletter] = [
        .dailyBytes,
        .weeklyDesign,
        .morningBrew,
        .designerNews
    ]

    public static let manyForScrolling: [HomeNewsletter] = (1...20).map { index in
        HomeNewsletter(
            id: index,
            brandName: "Brand \(index)",
            imageUrl: "https://picsum.photos/seed/newsletter\(index)/200",
            publicationCycle: index % 2 == 0 ? "매일" : "매주"
        )
    }
}

public enum SampleHomeMonthArticles {
    public static let empty: [HomeArticles] = []

    public static let currentMonth: [HomeArticles] = [
        HomeArticles(publishDate: 13, hasArticles: true, totalCount: 5, unreadCount: 2),
        HomeArticles(publishDate: 15, hasArticles: true, totalCount: 3, unreadCount: 3),
        HomeArticles(publishDate: 17, hasArticles: true, totalCount: 4, unreadCount: 1),
        HomeArticles(publishDate: 20, hasArticles: true, totalCount: 4, unreadCount: 4)
    ]
}
