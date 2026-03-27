//
//  MypageProfileUseCase.swift
//  MypageDomain
//
//  Created by 권민재 on 3/28/26.
//  Copyright © 2026 Newdok. All rights reserved.
//

import Foundation

public protocol MypageProfileUseCase {
    func fetchProfile() async throws -> MypageUser
    func updateNickname(_ nickname: String) async throws
    func updateIndustry(_ industryId: Int) async throws
    func updateInterests(_ interestIds: [Int]) async throws
    func updatePassword(prevPassword: String, newPassword: String) async throws
}
