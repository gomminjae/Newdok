//
//  MypageUserUseCase.swift
//  MypageDomain
//
//  Created by 권민재 on 3/28/26.
//  Copyright © 2026 Newdok. All rights reserved.
//

import Foundation
import Shared

public protocol MypageUserUseCase {
    func getProfile() async throws -> MypageUser
    func updateNickname(_ nickname: String) async throws -> MypageNicknameResponse
    func updatePassword(loginId: String, prevPassword: String, newPassword: String) async throws
    func updateInterest(_ interestsId: [Int]) async throws
    func updateIndustry(_ industryId: Int) async throws
    func updatePhoneNumber(_ phoneNumber: String) async throws
    func authSMS(phoneNumber: String) async throws -> MypageSMSResponse
    func checkPhoneNumber(_ phoneNumber: String) async throws -> [MypageSimpleUser]
    func checkIDDup(_ loginId: String) async throws -> CheckResult<MypageSimpleUser>
    func withdraw() async throws
}
