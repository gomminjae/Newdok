//
//  ArticleUseCase.swift
//  Domain
//
//  Created by 권민재 on 4/11/25.
//

import Foundation
import Shared


public protocol ArticleUseCase {
    
    func loadMonthlyArticles(year: String, month: String) async throws -> Articles

    func loadTodayArticles() async throws -> Articles

    func loadBookmarkedArticles(for interest: String) async throws -> BookmarkedArticles

    func toggleBookmark(for articleId: String) async throws

    func getBookmarkedInterests() async throws -> [Interest]

    func loadArticleDetail(id: String) async throws -> ArticleDetail
}
