//
//  ArticleRepository.swift
//  Domain
//
//  Created by 권민재 on 4/11/25.
//

import Foundation
import Shared


public protocol ArticleRepository {
    
    func fetchArticles(year: String, publicationMonth: String) async throws -> Articles
    
    func fetchTodayArticles() async throws -> Articles
    
    func fetchBookmarkArticles(interest: String) async throws -> BookmarkedArticles
    func changeBookmarkState(articleId: String) async throws
    
    func fetchBookmarkedInterest() async throws -> [Interest]
    
    func fetchArticleDetail(id: String) async throws -> ArticleDetail
    
    
}
