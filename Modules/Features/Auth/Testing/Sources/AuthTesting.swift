import Foundation
import AuthDomain

public final class MockLoginUseCase: LoginUseCase, @unchecked Sendable {
    public var result: Result<AuthUser, Error> = .success(
        AuthUser(id: 1, loginId: "test", phoneNumber: "010", subscribeEmail: nil,
                 nickname: "테스터", birthYear: "2000", gender: "M",
                 createdAt: "2025-01-01", industryId: nil, interestIds: [])
    )
    public private(set) var executedProvider: SocialProvider?
    public private(set) var executedIDToken: String?
    public private(set) var executeCallCount = 0

    public init() {}

    public func execute(provider: SocialProvider, idToken: String) async throws -> AuthUser {
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
