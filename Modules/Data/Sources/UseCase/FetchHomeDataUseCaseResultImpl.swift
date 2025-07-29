//
//  FetchHomeDataUseCaseResultImpl.swift
//  Data
//
//  Created by AI Assistant on 1/14/25.
//

import Foundation
import Domain
import Core
import Shared

public final class FetchHomeDataUseCaseResultImpl: FetchHomeDataUseCaseResult {
   
    private let newsletterRepo: NewsletterRepositoryResult
    private let articleRepo: ArticleRepositoryResult
    
    public init(newsletterRepo: NewsletterRepositoryResult, articleRepo: ArticleRepositoryResult) {
        self.newsletterRepo = newsletterRepo
        self.articleRepo = articleRepo
    }
    
    // MARK: - UseCase Methods with Result
    
    public func fetchTodayData() async -> AppResult<HomeData> {
        // 먼저 today 아티클을 가져오기
        let articlesResult = await articleRepo.fetchTodayArticles()
        
        // 아티클 조회 실패 시 에러 반환
        guard case .success(let articles) = articlesResult else {
            if case .failure(let error) = articlesResult {
                return .failure(error)
            }
            return .failure(.unknown("아티클 조회 실패"))
        }
        
        // 그 다음에 active 구독 가져오기
        let newslettersResult = await newsletterRepo.fetchActiveSubscription()
        
        // 뉴스레터 조회 실패 시 에러 반환
        guard case .success(let newsletters) = newslettersResult else {
            if case .failure(let error) = newslettersResult {
                return .failure(error)
            }
            return .failure(.unknown("뉴스레터 조회 실패"))
        }
        
        let homeData = HomeData(
            articles: articles,
            activeNewsletters: newsletters
        )
        
        return .success(homeData)
    }

    public func fetchMonthlyData(year: String, month: String) async -> AppResult<[Articles]> {
        // 입력 검증
        let validationResult = validateMonthlyDataRequest(year: year, month: month)
        if case .failure(let error) = validationResult {
            return .failure(error)
        }
        
        return await articleRepo.fetchArticlesByMonth(year: year, month: month)
    }
} 