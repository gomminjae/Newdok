//
//  FetchHomeDataUseCase.swift
//  Domain
//
//  Created by 권민재 on 4/19/25.
//

import Foundation
import Shared

public protocol FetchHomeDataUseCase {
    func fetchTodayData() async throws -> HomeData
    func fetchMonthlyData(year: String, month: String) async throws -> [Articles]
    func decorateTodayArticles(_ articles: [Article], readArticleIds: Set<Int>) -> [Article]
    func decorateMonthlyArticles(_ monthly: [Articles], readArticleIds: Set<Int>) -> [Articles]
    func unreadCount(in articles: [Article]) -> Int
}
