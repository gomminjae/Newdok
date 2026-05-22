import Foundation
import MypageDomain

public extension MypageInterest {
    static let tech = MypageInterest(id: 1, name: "테크")
    static let design = MypageInterest(id: 2, name: "디자인")
    static let business = MypageInterest(id: 3, name: "비즈니스")
    static let culture = MypageInterest(id: 4, name: "문화")
}

public extension MypageUser {
    static let standard = MypageUser(
        id: 1,
        loginId: "newdok_user",
        phoneNumber: "010-1234-5678",
        subscribeEmail: "newdok@example.com",
        nickname: "뉴독러",
        birthYear: "1995",
        gender: "F",
        createdAt: "2025-01-01",
        industryId: 1,
        interests: [.tech, .design, .business]
    )

    static let withoutEmail = MypageUser(
        id: 2,
        loginId: "no_email_user",
        phoneNumber: "010-9876-5432",
        subscribeEmail: nil,
        nickname: "이메일없음",
        birthYear: "1990",
        gender: "M",
        createdAt: "2025-05-01",
        industryId: nil,
        interests: []
    )
}

public enum SampleMypageUsers {
    public static let standard: MypageUser = .standard
    public static let withoutEmail: MypageUser = .withoutEmail
}

public enum SampleMypageInterests {
    public static let empty: [MypageInterest] = []

    public static let mixed: [MypageInterest] = [.tech, .design, .business, .culture]
}
