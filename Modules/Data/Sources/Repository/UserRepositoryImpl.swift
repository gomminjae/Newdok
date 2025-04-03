//
//  UserRepositoryImpl.swift
//  Data
//
//  Created by 권민재 on 3/27/25.
//
import Domain
import Network
import Foundation
import Moya


public final class UserRepositoryImpl: UserRepository {
    
    
    private let provider: MoyaProvider<UserAPI>
    
    public init(provider: MoyaProvider<UserAPI>) {
        self.provider = provider
    }
    
    
    public func login(loginId: String, password: String) async throws -> Domain.User {
        
        let response: UserDTO = try await provider.asyncRequest(.login(loginId: loginId, password: password))
        
        guard let user = response.toDomain() else {
            throw NetworkError.decodeError(underlying: NSError(domain: "Invalid userDTO", code: 0))
        }
        
        return user
    }
    
    public func signup(loginId: String, password: String, phoneNumber: String, nickname: String, birthYear: String, gender: String) async throws -> Domain.SignupResponse {
        
        let response: SignupResponseDTO = try await provider.asyncRequest(.signup(loginId: loginId, password: password, phoneNumber: phoneNumber, nickname: nickname, birthYear: birthYear, gender: gender))
        
        let signupResponse = response.toDomain()
        
        return signupResponse
        
    }
    
    public func checkPhoneNumber(_ phoneNumber: String) async throws -> [SimpleUser] {
        
        let response: [SimpleUserDTO] = try await provider.asyncRequest(.checkPhoneNumber(phoneNumber: phoneNumber))
        
        let users = response.compactMap { $0.toDomain() }
        
        if users.isEmpty {
            throw NetworkError.decodeError(underlying: NSError(domain: "SimpleUserDTO decode failed", code: 0))
        }
        
        
        return users
        
        
    }
    
    public func checkIDDup(_ loginId: String) async throws -> SimpleUser {
        let response: SimpleUserDTO = try await provider.asyncRequest(.checkIDDup(loginId: loginId))
        let user = response.toDomain()
        return user
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
    
    public func authSMS(phoneNumber: String) async throws {
        _ = try await
        provider.asyncVoidRequest(.authSMS(phoneNumber: phoneNumber))
    }
    
    public func preInvestigate(industryId: Int, interestIds: [Int]) async throws -> [Brand] {
        let response: BrandListResponseDTO = try await provider.asyncRequest(.preInvestigate(industryId: industryId, interestIds: interestIds))
        
        let brands = response.toDomain()
        
        return brands
        
    }
    
    
}
