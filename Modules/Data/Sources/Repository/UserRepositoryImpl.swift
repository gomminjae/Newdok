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
        let response = try await provider.asyncRequest(UserAPI.login(loginId: loginId, password: password))
        let userDTO = try JSONDecoder().decode(UserDTO.self, from: response.data)
        
        guard let user = userDTO.toDomain() else {
            throw NetworkError.decodeError
        }
        
        return user
        
    }
    
    public func signup(loginId: String, password: String, phoneNumber: String, nickname: String, birthYear: String, gender: String) async throws -> Domain.User {
        let response = try await provider.asyncRequest(UserAPI.signup(loginId: loginId, password: password, phoneNumber: phoneNumber, nickname: nickname, birthYear: birthYear, gender: gender))
        let userDTO = try JSONDecoder().decode(UserDTO.self, from: response.data)
        
        guard let user = userDTO.toDomain() else {
            throw NetworkError.decodeError
        }
        return user
    }
    
    public func checkPhoneNumber(_ phoneNumber: String) async throws -> Bool {
        let response =
    }
    
    public func checkIDDup(_ loginId: String) async throws -> Bool {
        <#code#>
    }
    
    public func updateNickname(_ nickname: String) async throws {
        <#code#>
    }
    
    public func updatePassword(loginId: String, prevPassword: String, newPassword: String) async throws {
        <#code#>
    }
    
    public func updateInterest(_ interestsId: [Int]) async throws {
        <#code#>
    }
    
    public func updateIndustry(_ industryId: Int) async throws {
        <#code#>
    }
    
    public func updatePhoneNumber(_ phoneNumber: String) async throws {
        <#code#>
    }
    
    public func authSMS(phoneNumber: String) async throws -> Bool {
        <#code#>
    }
    
    public func preInvestigate(industryId: Int, interestIds: [Int]) async throws {
        <#code#>
    }
    
    
}
