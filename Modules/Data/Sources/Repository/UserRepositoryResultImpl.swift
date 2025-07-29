//
//  UserRepositoryResultImpl.swift
//  Data
//
//  Created by AI Assistant on 1/14/25.
//

import Domain
import Core
import Foundation
import Moya
import Shared

public final class UserRepositoryResultImpl: UserRepositoryResult {
    
    private let provider: MoyaProvider<UserAPI>
    
    public init(provider: MoyaProvider<UserAPI>) {
        self.provider = provider
    }
    
    // MARK: - Repository Methods with Result
    
    public func login(loginId: String, password: String) async -> AppResult<(User, String)> {
        return await AppResult.catching {
            let response: LoginResponseDTO = try await self.provider.asyncRequest(.login(loginId: loginId, password: password))
            let user = response.user.toDomain()
            let token = response.accessToken
            return (user, token)
        }.mapError { error in
            self.mapToAppError(error)
        }
    }
    
    public func signup(loginId: String, password: String, phoneNumber: String, nickname: String, birthYear: String, gender: String) async -> AppResult<SignupResponse> {
        return await AppResult.catching {
            let response: SignupResponseDTO = try await self.provider.asyncRequest(.signup(loginId: loginId, password: password, phoneNumber: phoneNumber, nickname: nickname, birthYear: birthYear, gender: gender))
            return response.toDomain()
        }.mapError { error in
            self.mapToAppError(error)
        }
    }
    
    public func checkPhoneNumber(_ phoneNumber: String) async -> AppResult<[SimpleUser]> {
        return await AppResult.catching {
            do {
                let response: [SimpleUserDTO] = try await self.provider.asyncRequest(.checkPhoneNumber(phoneNumber: phoneNumber))
                return response.compactMap { $0.toDomain() }
            } catch let error as NetworkError {
                if case .serverError(let statusCode, _) = error, statusCode == 400 {
                    // 400: 가입된 사용자 없음 - 빈 배열 반환
                    return []
                } else {
                    throw error
                }
            }
        }.mapError { error in
            self.mapToAppError(error)
        }
    }
    
    public func checkIDDup(loginId: String) async -> AppResult<CheckResult> {
        return await AppResult.catching {
            let response: CheckResult = try await self.provider.asyncRequest(.checkIDDup(loginId: loginId))
            return response
        }.mapError { error in
            self.mapToAppError(error)
        }
    }
    
    public func updateNickname(nickname: String) async -> AppResult<User> {
        return await AppResult.catching {
            let response: UserDTO = try await self.provider.asyncRequest(.updateNickname(nickname: nickname))
            return response.toDomain()
        }.mapError { error in
            self.mapToAppError(error)
        }
    }
    
    public func updatePassword(loginId: String, prevPassword: String, password: String) async -> AppResult<Void> {
        return await AppResult.catching {
            try await self.provider.asyncVoidRequest(.updatePassword(loginId: loginId, prevPassword: prevPassword, password: password))
        }.mapError { error in
            self.mapToAppError(error)
        }
    }
    
    public func updateInterest(interestsId: [Int]) async -> AppResult<Void> {
        return await AppResult.catching {
            try await self.provider.asyncVoidRequest(.updateInterest(interestsId: interestsId))
        }.mapError { error in
            self.mapToAppError(error)
        }
    }
    
    public func updateIndustry(industryId: Int) async -> AppResult<Void> {
        return await AppResult.catching {
            try await self.provider.asyncVoidRequest(.updateIndustry(industryId: industryId))
        }.mapError { error in
            self.mapToAppError(error)
        }
    }
    
    public func updatePhoneNumber(phoneNumber: String) async -> AppResult<Void> {
        return await AppResult.catching {
            try await self.provider.asyncVoidRequest(.updatePhoneNumber(phoneNumber: phoneNumber))
        }.mapError { error in
            self.mapToAppError(error)
        }
    }
    
    public func authSMS(phoneNumber: String) async -> AppResult<Void> {
        return await AppResult.catching {
            try await self.provider.asyncVoidRequest(.authSMS(phoneNumber: phoneNumber))
        }.mapError { error in
            self.mapToAppError(error)
        }
    }
    
    public func preInvestigate(industryId: String, interestIds: [String]) async -> AppResult<[RecommendedBrand]> {
        return await AppResult.catching {
            let response: [RecommendedBrandDTO] = try await self.provider.asyncRequest(.preInvestigate(industryId: industryId, interestIds: interestIds))
            return response.map { $0.toDomain() }
        }.mapError { error in
            self.mapToAppError(error)
        }
    }
    
    public func profile() async -> AppResult<User> {
        return await AppResult.catching {
            let response: UserDTO = try await self.provider.asyncRequest(.profile)
            return response.toDomain()
        }.mapError { error in
            self.mapToAppError(error)
        }
    }
    
    public func withdraw() async -> AppResult<Void> {
        return await AppResult.catching {
            try await self.provider.asyncVoidRequest(.withdraw)
        }.mapError { error in
            self.mapToAppError(error)
        }
    }
    
    // MARK: - Error Mapping
    
    private func mapToAppError(_ error: Error) -> AppError {
        if let networkError = error as? NetworkError {
            return .network(self.mapNetworkError(networkError))
        } else if error.localizedDescription.contains("인증") {
            return .business(.sessionExpired)
        } else if error.localizedDescription.contains("중복") {
            return .validation(.duplicateValue("아이디"))
        } else {
            return .unknown(error.localizedDescription)
        }
    }
    
    private func mapNetworkError(_ error: NetworkError) -> NetworkError {
        return error // 이미 NetworkError이므로 그대로 반환
    }
} 