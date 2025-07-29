//
//  UserRepositoryResult.swift
//  Domain
//
//  Created by AI Assistant on 1/14/25.
//

import Foundation
import Shared

// MARK: - Result-based UserRepository
public protocol UserRepositoryResult {
    func login(loginId: String, password: String) async -> AppResult<(User, String)>
    func signup(loginId: String, password: String, phoneNumber: String, nickname: String, birthYear: String, gender: String) async -> AppResult<SignupResponse>
    func checkPhoneNumber(_ phoneNumber: String) async -> AppResult<[SimpleUser]>
    func checkIDDup(loginId: String) async -> AppResult<CheckResult>
    func updateNickname(nickname: String) async -> AppResult<User>
    func updatePassword(loginId: String, prevPassword: String, password: String) async -> AppResult<Void>
    func updateInterest(interestsId: [Int]) async -> AppResult<Void>
    func updateIndustry(industryId: Int) async -> AppResult<Void>
    func updatePhoneNumber(phoneNumber: String) async -> AppResult<Void>
    func authSMS(phoneNumber: String) async -> AppResult<Void>
    func preInvestigate(industryId: String, interestIds: [String]) async -> AppResult<[RecommendedBrand]>
    func profile() async -> AppResult<User>
    func withdraw() async -> AppResult<Void>
} 