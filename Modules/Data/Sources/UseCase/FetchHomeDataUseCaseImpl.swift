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
        
        async let articlesTask = articleRepo.fetchTodayArticles()
        async let newslettersTask = newsletterRepo.fetchActiveSubscription()
        
        let articles = try await articlesTask
        let newsletters = try await newslettersTask
        
        let articleList = articles
        
        return HomeData(
            articles: articleList,
            activeNewsletters: newsletters
        )
    }

    
    public func fetchMonthlyData(year: String, month: String) async throws -> [Domain.Articles] {
        let monthlyArticles = try await articleRepo.fetchArticles(year: year, publicationMonth: month)
        
        return monthlyArticles
        
    }
    
    
    
    
    
    
}
