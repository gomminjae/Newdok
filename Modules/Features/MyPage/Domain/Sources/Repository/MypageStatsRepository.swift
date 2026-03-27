//
//  MypageStatsRepository.swift
//  MypageDomain
//
//  Created by 권민재 on 3/28/26.
//  Copyright © 2026 Newdok. All rights reserved.
//

import Foundation

public protocol MypageStatsRepository {
    func fetchReceivedArticleCount() async throws -> Int
    func fetchSubscriptionCount() async throws -> Int
}
