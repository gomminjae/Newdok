//
//  FetchHomeDataUseCaseImpl.swift
//  Data
//
//  Created by 권민재 on 4/19/25.
//

import Domain
import Core
import Shared


public class FetchHomeDataUseCaseImpl: FetchHomeDataUseCase {
   
    
    private let newsletterRepo: NewsletterRepository
    private let articleRepo: ArticleRepository
    
    public init(newsletterRepo: NewsletterRepository, articleRepo: ArticleRepository) {
        self.newsletterRepo = newsletterRepo
        self.articleRepo = articleRepo
    }
    
    
    public func fetchTodayData() async throws -> Domain.HomeData {
        // 1. today 아티클을 먼저 가져오기
        let articles = try await articleRepo.fetchTodayArticles()
        
        // 2. 그 다음에 active 구독 가져오기  
        let newsletters = try await newsletterRepo.fetchActiveSubscription()

        return HomeData(
            articles: articles,
            activeNewsletters: newsletters
        )
    }


    
    public func fetchMonthlyData(year: String, month: String) async throws -> [Domain.Articles] {
        try await articleRepo.fetchArticles(year: year, publicationMonth: month)
    }
    
    public func fetchDayArticles(year: String, month: String, day: String) async throws -> [Article] {
        try await articleRepo.fetchDayArticles(year: year, publicationMonth: month, publicationDate: day)
    }
    
    public func decorateTodayArticles(_ articles: [Article], readArticleIds: Set<Int>) -> [Article] {
        let mapped = articles.map { applyReadStatus(to: $0, readArticleIds: readArticleIds) }
        return prioritize(mapped)
    }

    public func unreadCount(in articles: [Article]) -> Int {
        articles.reduce(into: 0) { count, article in
            if !isRead(article) { count += 1 }
        }
    }
    
    private func applyReadStatus(to article: Article, readArticleIds: Set<Int>) -> Article {
        guard readArticleIds.contains(article.articleId) else { return article }
        return Article(
            brandName: article.brandName,
            imageUrl: article.imageUrl,
            articleTitle: article.articleTitle,
            articleId: article.articleId,
            status: "Read",
            publishDate: article.publishDate
        )
    }
    
    private func prioritize(_ articles: [Article]) -> [Article] {
        articles.sorted { lhs, rhs in
            let lhsRead = isRead(lhs)
            let rhsRead = isRead(rhs)
            
            if lhsRead != rhsRead {
                return !lhsRead
            }
            
            return lhs.articleId > rhs.articleId
        }
    }
    
    private func isRead(_ article: Article) -> Bool {
        article.status.caseInsensitiveCompare("Read") == .orderedSame
    }
    
}
