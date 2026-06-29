import Foundation

public protocol AuthRepository: Sendable {
    func login(provider: SocialProvider, idToken: String) async throws -> (AuthUser, String)
    func signup(
        loginId: String,
        password: String,
        phoneNumber: String,
        nickname: String,
        birthYear: String,
        gender: String
    ) async throws -> AuthSignupResponse
    func checkPhoneNumber(_ phoneNumber: String) async throws -> [AuthSimpleUser]
    func checkIDDup(_ loginId: String) async throws -> AuthIDCheckResult
    func authSMS(phoneNumber: String) async throws -> AuthSMSResponse
    func preInvestigate(industryId: String, interestIds: [String]) async throws -> [AuthRecommendedBrand]
    func signOut() async
}
