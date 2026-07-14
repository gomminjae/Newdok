import Foundation
import MypageDomain

public final class MockFetchMypageProfileUseCase: FetchMypageProfileUseCase {
    public var result: Result<MypageUser, Error> = .success(
        MypageUser(id: 1, subscribeEmail: "test@test.com", nickname: "테스트", birthYear: "2000", gender: "M", createdAt: "2025-01-01", industryId: 1, interests: [])
    )
    public private(set) var executeCallCount = 0

    public init() {}

    public func execute() async throws -> MypageUser {
        executeCallCount += 1
        return try result.get()
    }
}
