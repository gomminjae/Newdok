import Foundation
import AuthDomain
import Core
import Moya
import Shared

public final class AuthRepositoryImpl: AuthRepository {
    private let provider: MoyaProvider<UserAPI>

    public init(provider: MoyaProvider<UserAPI>) {
        self.provider = provider
    }

    public func login(loginId: String, password: String) async throws -> (AuthUser, String) {
        do {
            let response: AuthLoginResponseDTO = try await provider.asyncRequest(
                .login(loginId: loginId, password: password)
            )
            let user = response.user.toDomain()
            let token = response.accessToken
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
        let response: AuthSignupResponseDTO = try await provider.asyncRequest(
            .signup(
                loginId: loginId,
                password: password,
                phoneNumber: phoneNumber,
                nickname: nickname,
                birthYear: birthYear,
                gender: gender
            )
        )
        return response.toDomain()
    }

    public func checkPhoneNumber(_ phoneNumber: String) async throws -> [AuthSimpleUser] {
        do {
            let response: [AuthSimpleUserDTO] = try await provider.asyncRequest(
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
        let result = try await provider.safeCheckRequest(
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
        let response: AuthSMSResponseDTO = try await provider.asyncRequest(
            .authSMS(phoneNumber: phoneNumber)
        )
        return response.toDomain()
    }

    public func preInvestigate(
        industryId: String,
        interestIds: [String]
    ) async throws -> [AuthRecommendedBrand] {
        let response: AuthRecommendedBrandListResponseDTO = try await provider.asyncRequest(
            .preInvestigate(industryId: industryId, interestIds: interestIds)
        )
        return response.toDomain()
    }
}
