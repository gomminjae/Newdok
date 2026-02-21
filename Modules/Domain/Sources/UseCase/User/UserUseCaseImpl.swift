//
//  UserUseCaseImpl.swift
//  Domain
//
//  Created by 권민재 on 3/27/25.
//
import Foundation
import Shared

public final class UserUseCaseImpl: UserUseCase {
    private let userRepository: UserRepository
    
    public init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    public func login(loginId: String, password: String) async throws -> (User, String) {
        return try await userRepository.login(loginId: loginId, password: password)
    }
    
    public func signup(loginId: String, password: String, phoneNumber: String, nickname: String, birthYear: String, gender: String) async throws -> Domain.SignupResponse {
        return try await userRepository.signup(loginId: loginId, password: password, phoneNumber: phoneNumber, nickname: nickname, birthYear: birthYear, gender: gender)
    }
    
    public func checkPhoneNumber(_ phoneNumber: String) async throws -> [Domain.SimpleUser] {
        return try await userRepository.checkPhoneNumber(phoneNumber)
    }
    
    public func checkIDDup(_ loginId: String) async throws -> CheckResult<SimpleUser> {
        return try await userRepository.checkIDDup(loginId)
    }
    
    public func updateNickname(_ nickname: String) async throws -> Domain.NicknameResponse {
        return try await userRepository.updateNickname(nickname)
    }
    
    public func updatePassword(loginId: String, prevPassword: String, newPassword: String) async throws {
        return try await userRepository.updatePassword(loginId: loginId, prevPassword: prevPassword, newPassword: newPassword)
    }
    
    public func updateInterest(_ interestsId: [Int]) async throws {
        return try await userRepository.updateInterest(interestsId)
    }
    
    public func updateIndustry(_ industryId: Int) async throws {
        return try await userRepository.updateIndustry(industryId)
    }
    
    public func updatePhoneNumber(_ phoneNumber: String) async throws {
        return try await userRepository.updatePhoneNumber(phoneNumber)
    }
    
    public func authSMS(phoneNumber: String) async throws -> SMSResponse {
        return try await userRepository.authSMS(phoneNumber: phoneNumber)
    }
    
    public func preInvestigate(industryId: String, interestIds: [String]) async throws -> [Domain.RecommendedBrand] {
        return try await userRepository.preInvestigate(industryId: industryId, interestIds: interestIds)
    }
    
    public func getProfile() async throws -> Domain.User {
        return try await userRepository.getProfile()
    }
    
    public func withdraw() async throws {
        try await userRepository.withdraw()
    }
}
