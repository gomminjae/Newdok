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
        let monthlyArticles = try await articleRepo.fetchArticles(year: year, publicationMonth: month)
        
        return monthlyArticles
        
    }
    
    
    
    
    
    
}
