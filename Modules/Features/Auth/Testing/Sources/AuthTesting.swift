import Foundation
import AuthDomain

public final class MockLoginUseCase: LoginUseCase, @unchecked Sendable {
    public var result: Result<AuthUser, Error> = .success(
        AuthUser(id: 1, loginId: "test", phoneNumber: "010", subscribeEmail: nil,
                 nickname: "테스터", birthYear: "2000", gender: "M",
                 createdAt: "2025-01-01", industryId: nil, interestIds: [])
    )
    public private(set) var executedLoginId: String?
    public private(set) var executedPassword: String?
    public private(set) var executeCallCount = 0

    public init() {}

    public func execute(loginId: String, password: String) async throws -> AuthUser {
        executeCallCount += 1
        executedLoginId = loginId
        executedPassword = password
        return try result.get()
    }
}
