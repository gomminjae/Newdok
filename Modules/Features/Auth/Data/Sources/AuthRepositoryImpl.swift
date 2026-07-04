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

    public func login(loginId: String, password: String) async throws -> (AuthUser, String) {
        let user: AuthUser
        let token: String
        do {
            let response = try await network.request(
                Login(loginId: loginId, password: password)
            )
            user = response.user.toDomain()
            token = response.accessToken
        } catch let error as NetworkError {
            if case .serverError(let statusCode, let message) = error, statusCode == 400 {
                let errorMessage = message ?? ""
                if errorMessage.contains("비밀번호") {
                    throw LoginError.invalidPassword
                } else if errorMessage.contains("계정") {
                    throw LoginError.accountNotFound
                }
            }
            throw LoginError.networkError(error)
        } catch {
            throw LoginError.networkError(error)
        }

        // Keychain 저장 실패 시 로그인 실패로 처리 — 다음 실행 때 조용히 로그아웃되는 것 방지.
        guard tokenStorage.saveAccessToken(token) else {
            throw LoginError.tokenPersistenceFailed
        }
        persistLocalUser(from: user)

        return (user, token)
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

        guard tokenStorage.saveAccessToken(domain.accessToken) else {
            throw LoginError.tokenPersistenceFailed
        }
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
