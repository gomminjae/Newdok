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
    public private(set) var executedCredential: SocialLoginCredential?
    public private(set) var executeCallCount = 0

    public init() {}

    public func execute(credential: SocialLoginCredential) async throws -> SocialLoginResultType {
        executeCallCount += 1
        executedCredential = credential
        return try result.get()
    }
}

@MainActor
public final class MockKakaoAuthService: KakaoAuthServiceProtocol {
    public var result: Result<String, Error> = .success("mock-id-token")

    public nonisolated init() {}

    public func fetchIDToken() async throws -> String {
        try result.get()
    }
}

@MainActor
public final class MockAppleAuthService: AppleAuthServiceProtocol {
    public var result: Result<AppleAuthCredential, Error> = .success(
        AppleAuthCredential(idToken: "apple-id-token", authorizationCode: "apple-authorization-code")
    )

    public nonisolated init() {}

    public func fetchCredential() async throws -> AppleAuthCredential {
        try result.get()
    }
}
