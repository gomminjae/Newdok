import Foundation

public struct AuthSignupRequest {
    public let signupToken: String
    public let nickname: String
    public let birthYear: String
    public let gender: String
    public let agreements: [AuthAgreement]

    public init(
        signupToken: String,
        nickname: String,
        birthYear: String,
        gender: String,
        agreements: [AuthAgreement]
    ) {
        self.signupToken = signupToken
        self.nickname = nickname
        self.birthYear = birthYear
        self.gender = gender
        self.agreements = agreements
    }
}

public protocol SignupUseCase: Sendable {
    func execute(request: AuthSignupRequest) async throws -> AuthUser
}
