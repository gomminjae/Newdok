import Foundation

public struct AuthSignupRequest {
    public let loginId: String
    public let password: String
    public let phoneNumber: String
    public let nickname: String
    public let birthYear: String
    public let gender: String

    public init(
        loginId: String,
        password: String,
        phoneNumber: String,
        nickname: String,
        birthYear: String,
        gender: String
    ) {
        self.loginId = loginId
        self.password = password
        self.phoneNumber = phoneNumber
        self.nickname = nickname
        self.birthYear = birthYear
        self.gender = gender
    }
}

public protocol SignupUseCase: Sendable {
    func execute(request: AuthSignupRequest) async throws -> AuthUser
}
