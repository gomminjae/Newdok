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
    func fetchDayArticles(year: String, month: String, day: String) async throws -> [Article]
    func decorateTodayArticles(_ articles: [Article], readArticleIds: Set<Int>) -> [Article]
    func unreadCount(in articles: [Article]) -> Int
    func refresh() async throws
}
