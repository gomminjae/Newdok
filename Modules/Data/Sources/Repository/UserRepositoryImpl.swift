//
//  UserRepositoryImpl.swift
//  Data
//
//  Created by 권민재 on 3/27/25.
//
import Domain
import Core
import Foundation
import Moya
import Shared


public final class UserRepositoryImpl: UserRepository {
  
    
    
    private let provider: MoyaProvider<UserAPI>
    
    public init(provider: MoyaProvider<UserAPI>) {
        self.provider = provider
    }
    
    
    public func login(loginId: String, password: String) async throws -> (User,String) {
        
        let response: LoginResponseDTO = try await provider.asyncRequest(.login(loginId: loginId, password: password))
        let user = response.user.toDomain()
        let token = response.accessToken
        
        return (user,token)
        
        
    }
    
    public func signup(loginId: String, password: String, phoneNumber: String, nickname: String, birthYear: String, gender: String) async throws -> Domain.SignupResponse {
        
        print("📡 [UserRepositoryImpl] 회원가입 API 요청:")
        print("  - loginId: '\(loginId)'")
        print("  - password: '\(password)' (길이: \(password.count))")
        print("  - phoneNumber: '\(phoneNumber)'")
        print("  - nickname: '\(nickname)'")
        print("  - birthYear: '\(birthYear)'")
        print("  - gender: '\(gender)'")
        
        let response: SignupResponseDTO = try await provider.asyncRequest(.signup(loginId: loginId, password: password, phoneNumber: phoneNumber, nickname: nickname, birthYear: birthYear, gender: gender))
        
        print("✅ [UserRepositoryImpl] 회원가입 API 응답 성공")
        
        let signupResponse = response.toDomain()
        
        return signupResponse
        
    }
    
    public func checkPhoneNumber(_ phoneNumber: String) async throws -> [SimpleUser] {
        do {
            let response: [SimpleUserDTO] = try await provider.asyncRequest(.checkPhoneNumber(phoneNumber: phoneNumber))
            let users = response.compactMap { $0.toDomain() }
            return users
        } catch let error as NetworkError {
            if case .serverError(let statusCode, _) = error, statusCode == 400 {
                // 400: 가입된 사용자 없음 빈 배열 반환
                return []
            } else {
                throw error
            }
        } catch {
            throw error
        }
    }
    
    public func checkIDDup(_ loginId: String) async throws -> CheckResult<SimpleUser> {
        let result = try await provider.safeCheckRequest(.checkIDDup(loginId: loginId),decodeTo: SimpleUserDTO.self)
        
        switch result {
        case .exists(let dto):
            return .exists(dto.toDomain())
        case .notFound:
            return .notFound
        }
        
    }
    
    public func updateNickname(_ nickname: String) async throws -> NicknameResponse {
        let response: NicknameResponseDTO = try await provider.asyncRequest(.updateNickname(nickname: nickname))
        let checked = response.toDomain()
        return checked
    }
    
    public func updatePassword(loginId: String, prevPassword: String, newPassword: String) async throws {
        _ = try await provider.asyncVoidRequest(.updatePassword(loginId: loginId, prevPassword: prevPassword, password: newPassword))
    }
    
    public func updateInterest(_ interestsId: [Int]) async throws {
        _ = try await provider.asyncVoidRequest(.updateInterest(interestsId: interestsId))
    }
    
    public func updateIndustry(_ industryId: Int) async throws {
        _ = try await
        provider.asyncVoidRequest(.updateIndustry(industryId: industryId))
    }
    
    public func updatePhoneNumber(_ phoneNumber: String) async throws {
        _ = try await
        provider.asyncVoidRequest(.updatePhoneNumber(phoneNumber: phoneNumber))
    }
    
    public func authSMS(phoneNumber: String) async throws -> SMSResponse {
        let response: SMSResponseDTO = try await provider.asyncRequest(.authSMS(phoneNumber: phoneNumber))
        let code = response.toDomain()
        
        return code
    }
    
    public func preInvestigate(industryId: String, interestIds: [String]) async throws -> [RecommendedBrand] {
        let response: RecommendedBrandListResponseDTO = try await provider.asyncRequest(.preInvestigate(industryId: industryId, interestIds: interestIds))
        
        let brands = response.toDomain()
        
        return brands
        
    }
    
    public func getProfile() async throws -> Domain.User {
        let response: UserDTO = try await provider.asyncRequest(.profile)
        
        let user = response.toDomain()
        
        return user 
    }
    
    public func withdraw() async throws {
        _ = try await provider.asyncVoidRequest(.withdraw)
    }
    
    
}
