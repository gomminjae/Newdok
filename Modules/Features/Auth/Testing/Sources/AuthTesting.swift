import Foundation
import AuthDomain

public final class MockLoginUseCase: LoginUseCase, @unchecked Sendable {
    public var result: Result<SocialLoginResultType, Error> = .success(
        .registered(
            AuthUser(id: 1, subscribeEmail: nil,
                     nickname: "테스터", birthYear: "2000", gender: "남자",
                     createdAt: "2025-01-01", industryId: nil, interestIds: []),
            accessToken: "mock-access-token"
        )
    )
    public private(set) var executedProvider: SocialProvider?
    public private(set) var executedIDToken: String?
    public private(set) var executeCallCount = 0

    public init() {}

    public func execute(provider: SocialProvider, idToken: String) async throws -> SocialLoginResultType {
        executeCallCount += 1
        executedProvider = provider
        executedIDToken = idToken
        return try result.get()
    }
}

@MainActor
public final class MockKakaoAuthService: KakaoAuthServiceProtocol {
    public var result: Result<String, Error> = .success("mock-id-token")

    public init() {}

    public func fetchIDToken() async throws -> String {
        try result.get()
    }
}
