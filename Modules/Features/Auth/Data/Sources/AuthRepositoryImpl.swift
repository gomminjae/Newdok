import Foundation
import AuthDomain
import Core
import Shared

public final class AuthRepositoryImpl: AuthRepository {
    private let network: any NetworkService<UserAPI>
    private var tokenStorage: TokenStorageProtocol
    private let userInfoStore: UserInfoStoreProtocol

    public init(
        network: any NetworkService<UserAPI>,
        tokenStorage: TokenStorageProtocol = TokenStorageWrapper.shared,
        userInfoStore: UserInfoStoreProtocol = UserInfoStore.shared
    ) {
        self.network = network
        self.tokenStorage = tokenStorage
        self.userInfoStore = userInfoStore
    }

    public func login(loginId: String, password: String) async throws -> (AuthUser, String) {
        do {
            let response: AuthLoginResponseDTO = try await network.request(
                .login(loginId: loginId, password: password)
            )
            let user = response.user.toDomain()
            let token = response.accessToken

            tokenStorage.accessToken = token
            persistLocalUser(from: user)

            return (user, token)
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
    }

    public func signup(
        loginId: String,
        password: String,
        phoneNumber: String,
        nickname: String,
        birthYear: String,
        gender: String
    ) async throws -> AuthSignupResponse {
        let response: AuthSignupResponseDTO = try await network.request(
            .signup(
                loginId: loginId,
                password: password,
                phoneNumber: phoneNumber,
                nickname: nickname,
                birthYear: birthYear,
                gender: gender
            )
        )
        let domain = response.toDomain()

        tokenStorage.accessToken = domain.accessToken
        persistLocalUser(from: domain.user)

        return domain
    }

    public func checkPhoneNumber(_ phoneNumber: String) async throws -> [AuthSimpleUser] {
        do {
            let response: [AuthSimpleUserDTO] = try await network.request(
                .checkPhoneNumber(phoneNumber: phoneNumber)
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

    public func checkIDDup(_ loginId: String) async throws -> CheckResult<AuthSimpleUser> {
        let result = try await network.checkRequest(
            .checkIDDup(loginId: loginId),
            decodeTo: AuthSimpleUserDTO.self
        )
        switch result {
        case .exists(let dto):
            return .exists(dto.toDomain())
        case .notFound:
            return .notFound
        }
    }

    public func authSMS(phoneNumber: String) async throws -> AuthSMSResponse {
        let response: AuthSMSResponseDTO = try await network.request(
            .authSMS(phoneNumber: phoneNumber)
        )
        return response.toDomain()
    }

    public func preInvestigate(
        industryId: String,
        interestIds: [String]
    ) async throws -> [AuthRecommendedBrand] {
        let response: AuthRecommendedBrandListResponseDTO = try await network.request(
            .preInvestigate(industryId: industryId, interestIds: interestIds)
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
