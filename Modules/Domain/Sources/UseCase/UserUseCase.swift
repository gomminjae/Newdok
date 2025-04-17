//
//  UserUseCase.swift
//  Domain
//
//  Created by 권민재 on 3/27/25.
//

import Foundation
import Shared

public protocol UserUseCase {
    func login(loginId: String, password: String) async throws -> (User,String)
    func signup(loginId: String, password: String, phoneNumber: String, nickname: String, birthYear: String, gender: String) async throws -> SignupResponse
    func checkPhoneNumber(_ phoneNumber: String) async throws -> [SimpleUser]
    func checkIDDup(_ loginId: String) async throws -> CheckResult<SimpleUser>

    func updateNickname(_ nickname: String) async throws -> NicknameResponse
    func updatePassword(loginId: String, prevPassword: String, newPassword: String) async throws
    func updateInterest(_ interestsId: [Int]) async throws
    func updateIndustry(_ industryId: Int) async throws
    func updatePhoneNumber(_ phoneNumber: String) async throws

    func authSMS(phoneNumber: String) async throws -> SMSResponse
    func preInvestigate(industryId: String, interestIds: [String]) async throws -> [RecommendedBrand]
}
