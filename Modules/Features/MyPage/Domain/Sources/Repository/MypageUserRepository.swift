//
//  MypageUserRepository.swift
//  MypageDomain
//
//  Created by 권민재 on 3/28/26.
//  Copyright © 2026 Newdok. All rights reserved.
//

import Foundation

public protocol MypageUserRepository: Sendable {
    func getProfile() async throws -> MypageUser
    func updateNickname(_ nickname: String) async throws -> MypageNicknameResponse
    func updateInterest(_ interestsId: [Int]) async throws
    func updateIndustry(_ industryId: Int) async throws
    func withdraw() async throws
}
