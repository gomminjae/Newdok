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

    public func login(provider: SocialProvider, idToken: String) async throws -> (AuthUser, String) {
        do {
            let response = try await network.request(
                Login(provider: provider.rawValue, idToken: idToken)
            )
            let user = response.user.toDomain()
            let token = response.accessToken

            tokenStorage.saveAccessToken(token)
            persistLocalUser(from: user)

            return (user, token)
        } catch let error as NetworkError {
            throw LoginError.networkError(error)
        } catch {
            throw LoginError.networkError(error)
        }
    }

    public func signup(
        loginId: String,
        password: String,
        phoneNumber: String,
        nickname: String,
        birthYear: String,
        gender: String
    ) async throws -> AuthSignupResponse {
        let response = try await network.request(
            Signup(
                loginId: loginId,
                password: password,
                phoneNumber: phoneNumber,
                nickname: nickname,
                birthYear: birthYear,
                gender: gender
            )
        )
        let domain = response.toDomain()

        tokenStorage.saveAccessToken(domain.accessToken)
        persistLocalUser(from: domain.user)

        return domain
    }

    public func checkPhoneNumber(_ phoneNumber: String) async throws -> [AuthSimpleUser] {
        do {
            let response = try await network.request(
                CheckPhoneNumber(phoneNumber: phoneNumber)
            )
            return response.map { $0.toDomain() }
        } catch let error as NetworkError {
            if case .serverError(let statusCode, _) = error, statusCode == 400 {
                return []
            } else {
                throw error
            }
        } catch {
            throw error
        }
    }

    public func checkIDDup(_ loginId: String) async throws -> AuthIDCheckResult {
        let result = try await network.checkRequest(
            CheckIDDup(loginId: loginId)
        )
        switch result {
        case .exists(let dto):
            return .exists(dto.toDomain())
        case .notFound:
            return .notFound
        }
    }

    public func authSMS(phoneNumber: String) async throws -> AuthSMSResponse {
        let response = try await network.request(
            AuthSMS(phoneNumber: phoneNumber)
        )
        return response.toDomain()
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
            loginId: user.loginId,
            phoneNumber: user.phoneNumber,
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
