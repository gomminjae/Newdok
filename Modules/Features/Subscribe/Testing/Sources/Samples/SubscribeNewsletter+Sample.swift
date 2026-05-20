import Foundation
import SubscribeDomain

public extension SubscribeNewsletter {
    static let dailyBytes = SubscribeNewsletter(
        id: 1,
        brandName: "Daily Bytes",
        imageUrl: "https://picsum.photos/seed/db/200",
        publicationCycle: "매일"
    )

    static let weeklyDesign = SubscribeNewsletter(
        id: 2,
        brandName: "Weekly Design",
        imageUrl: "https://picsum.photos/seed/wd/200",
        publicationCycle: "매주 월요일"
    )

    static let morningBrew = SubscribeNewsletter(
        id: 3,
        brandName: "Morning Brew",
        imageUrl: "https://picsum.photos/seed/mb/200",
        publicationCycle: "평일 매일"
    )

    static let techTrends = SubscribeNewsletter(
        id: 4,
        brandName: "Tech Trends",
        imageUrl: "https://picsum.photos/seed/tt/200",
        publicationCycle: "매주 금요일"
    )

    static let designerNews = SubscribeNewsletter(
        id: 5,
        brandName: "Designer News",
        imageUrl: "https://picsum.photos/seed/dn/200",
        publicationCycle: "매주 수요일"
    )
}

public enum SampleSubscriptions {
    public static let empty: [SubscribeNewsletter] = []

    public static let single: [SubscribeNewsletter] = [.dailyBytes]

    public static let mixed: [SubscribeNewsletter] = [
        .dailyBytes,
        .weeklyDesign,
        .morningBrew,
        .designerNews
    ]

    public static let manyForScrolling: [SubscribeNewsletter] = (1...20).map {
        SubscribeNewsletter(
            id: $0,
            brandName: "Brand \($0)",
            imageUrl: "https://picsum.photos/seed/brand\($0)/200",
            publicationCycle: $0 % 2 == 0 ? "매일" : "매주"
        )
    }

    public static let paused: [SubscribeNewsletter] = [.techTrends]
}
