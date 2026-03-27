//
//  MypageStatsUseCaseImpl.swift
//  MypageDomain
//
//  Created by 권민재 on 3/28/26.
//  Copyright © 2026 Newdok. All rights reserved.
//

import Foundation

public final class MypageStatsUseCaseImpl: MypageStatsUseCase {
    private let repository: MypageStatsRepository

    public init(repository: MypageStatsRepository) {
        self.repository = repository
    }

    public func fetchReceivedArticleCount() async throws -> Int {
        try await repository.fetchReceivedArticleCount()
    }

    public func fetchSubscriptionCount() async throws -> Int {
        try await repository.fetchSubscriptionCount()
    }
}
