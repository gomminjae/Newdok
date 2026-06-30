import Foundation
import AuthDomain
import NetworkKit
import Shared

public final class AuthRepositoryImpl: AuthRepository {
    private let network: any NetworkService
    private let tokenStorage: TokenStorageProtocol
    private let userInfoStore: UserInfoStoreProtocol

    public init(
        network: any NetworkService,
        tokenStorage: TokenStorageProtocol,
        userInfoStore: UserInfoStoreProtocol
    ) {
        self.network = network
        self.tokenStorage = tokenStorage
        self.userInfoStore = userInfoStore
    }

    public func login(provider: SocialProvider, idToken: String) async throws -> SocialLoginResultType {
        do {
            let response = try await network.request(
                Login(provider: provider.rawValue, idToken: idToken)
            )
            let result = try response.toDomain()

            if case let .registered(user, accessToken) = result {
                tokenStorage.saveAccessToken(accessToken)
                persistLocalUser(from: user)
            }

            return result
        } catch let error as LoginError {
            throw error
        } catch {
            throw LoginError.networkError(error)
        }
    }

    public func signup(
        signupToken: String,
        nickname: String,
        birthYear: String,
        gender: String,
        agreements: [AuthAgreement]
    ) async throws -> AuthSignupResponse {
        let response = try await network.request(
            SocialSignup(
                signupToken: signupToken,
                nickname: nickname,
                birthYear: birthYear,
                gender: gender,
                agreements: agreements.map {
                    SocialSignupAgreementRequest(type: $0.type.rawValue, agreed: $0.agreed)
                }
            )
        )
        let domain = response.toDomain()

        tokenStorage.saveAccessToken(domain.accessToken)
        persistLocalUser(from: domain.user)

        return domain
    }

    public func preInvestigate(
        industryId: String,
        interestIds: [String]
    ) async throws -> [AuthRecommendedBrand] {
        let response = try await network.request(
            PreInvestigate(industryId: industryId, interestIds: interestIds)
        )
        return response.toDomain()
    }

    public func signOut() async {
        tokenStorage.clear()
        userInfoStore.clear()
    }

    private func persistLocalUser(from user: AuthUser) {
        let userInfo = UserInfo(
            id: user.id,
            loginId: "",
            phoneNumber: "",
            subscribeEmail: user.subscribeEmail,
            nickname: user.nickname,
            birthYear: user.birthYear,
            gender: user.gender,
            createdAt: user.createdAt,
            industryId: user.industryId,
            interestIds: user.interestIds
        )
        userInfoStore.save(userInfo)
    }
}
