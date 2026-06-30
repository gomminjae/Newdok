import Foundation

public protocol AuthRepository: Sendable {
    func login(provider: SocialProvider, idToken: String) async throws -> SocialLoginResultType
    func signup(
        signupToken: String,
        nickname: String,
        birthYear: String,
        gender: String,
        agreements: [AuthAgreement]
    ) async throws -> AuthSignupResponse
    func preInvestigate(industryId: String, interestIds: [String]) async throws -> [AuthRecommendedBrand]
    func signOut() async
}
