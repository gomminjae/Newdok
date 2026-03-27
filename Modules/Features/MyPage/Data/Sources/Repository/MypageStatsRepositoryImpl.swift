//
//  MypageStatsRepositoryImpl.swift
//  MypageData
//
//  Created by 권민재 on 3/28/26.
//  Copyright © 2026 Newdok. All rights reserved.
//

import Foundation
import MypageDomain
import Core
import Moya

public final class MypageStatsRepositoryImpl: MypageStatsRepository {
    private let articleProvider: MoyaProvider<ArticleAPI>
    private let newsletterProvider: MoyaProvider<NewsletterAPI>

    public init(
        articleProvider: MoyaProvider<ArticleAPI>,
        newsletterProvider: MoyaProvider<NewsletterAPI>
    ) {
        self.articleProvider = articleProvider
        self.newsletterProvider = newsletterProvider
    }

    public func fetchReceivedArticleCount() async throws -> Int {
        let response: MypageArticlesCountDTO = try await articleProvider.asyncRequest(.fetchReceivedArticleCount)
        return response.count
    }

    public func fetchSubscriptionCount() async throws -> Int {
        let response: MypageNewslettersCountDTO = try await newsletterProvider.asyncRequest(.fetchSubscriptionCount)
        return response.count
    }
}
