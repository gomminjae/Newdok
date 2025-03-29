//
//  UserUseCaseImpl.swift
//  Data
//
//  Created by 권민재 on 3/27/25.
//
import Foundation
import Network
import Domain


public final class UserUseCaseImpl: UserUseCase {
    public func login(loginId: String, password: String) async throws -> Domain.User {
        <#code#>
    }
    
    public func signup(loginId: String, password: String, phoneNumber: String, nickname: String, birthYear: String, gender: String) async throws -> Domain.User {
        <#code#>
    }
    
    public func checkPhoneNumber(_ phoneNumber: String) async throws -> Bool {
        <#code#>
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
