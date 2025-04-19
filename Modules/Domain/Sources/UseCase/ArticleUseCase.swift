//
//  ArticleUseCase.swift
//  Domain
//
//  Created by 권민재 on 4/11/25.
//

import Foundation
import Shared


public protocol ArticleUseCase {

    
    func fetchArticlesByMonth(year: String, month: String) async throws -> [Articles]

    
    func fetchTodayArticles() async throws -> Articles

    func fetchBookmarkedArticles(interest: String) async throws -> BookmarkedArticles

  
    func toggleBookmarkStatus(articleId: String) async throws

    
    func fetchBookmarkedInterests() async throws -> [Interest]

  
    func fetchArticleDetail(articleId: String) async throws -> ArticleDetail
}
