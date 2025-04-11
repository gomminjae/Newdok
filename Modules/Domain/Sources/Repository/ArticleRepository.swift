//
//  ArticleRepository.swift
//  Domain
//
//  Created by 권민재 on 4/11/25.
//

import Foundation
import Shared


public protocol ArticleRepository {
    
    func fetchArticles(year: String, publicationMonth: String) -> Articles
    
    func fetchTodayArticles() -> Articles
    
    func fetchBookmarkArticles(interest: String) -> BookmarkedArticles
    func changeBookmarkState(articleId: String)
    
    func fetchBookmarkedInterest() -> [Interest]
    
    func fetchArticleDetail(id: String) -> ArticleDetail
    
    
}
