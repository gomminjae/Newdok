//
//  UserUseCase.swift
//  Domain
//
//  Created by 권민재 on 3/27/25.
//

import Foundation

public protocol UserUseCase {
    func login(loginId: String, password: String) async throws -> User
    func signup(loginId: String, password: String, phoneNumber: String, nickname: String, birthYear: String, gender: String) async throws -> User

    func checkPhoneNumber(_ phoneNumber: String) async throws -> Bool
    func checkIDDup(_ loginId: String) async throws -> Bool

    func updateNickname(_ nickname: String) async throws
    func updatePassword(loginId: String, prevPassword: String, newPassword: String) async throws
    func updateInterest(_ interestsId: [Int]) async throws
    func updateIndustry(_ industryId: Int) async throws
    func updatePhoneNumber(_ phoneNumber: String) async throws

    func authSMS(phoneNumber: String) async throws -> Bool
    func preInvestigate(industryId: Int, interestIds: [Int]) async throws
}
