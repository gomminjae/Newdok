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

    public func login(credential: SocialLoginCredential) async throws -> SocialLoginResultType {
        do {
            let request: Login
            switch credential {
            case let .kakao(idToken):
                request = Login(
                    provider: SocialProvider.kakao.rawValue,
                    idToken: idToken,
                    authorizationCode: nil
                )
            case let .apple(idToken, authorizationCode):
                request = Login(
                    provider: SocialProvider.apple.rawValue,
                    idToken: idToken,
                    authorizationCode: authorizationCode
                )
            }

            let response = try await network.request(request)
            let result = try response.toDomain()

            if case let .registered(user, accessToken) = result {
                // Keychain 저장 실패 시 로그인 실패로 처리 — 다음 실행 때 조용히 로그아웃되는 것 방지.
                guard tokenStorage.saveAccessToken(accessToken) else {
                    throw LoginError.tokenPersistenceFailed
                }
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

        guard tokenStorage.saveAccessToken(domain.accessToken) else {
            throw LoginError.tokenPersistenceFailed
        }
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
