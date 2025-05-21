//
//  NewsletterRepository.swift
//  Domain
//
//  Created by 권민재 on 4/18/25.
//

import Foundation
import Shared


public protocol NewsletterRepository {
    //MARK: 구독 상태
    func fetchActiveSubscription() async throws -> [Newsletter]
    func fetchPausedSubscription() async throws -> [Newsletter]
    
    //MARK: 추천
    func fetchRecommenidation() async throws -> RecommendedNewsletter
    
    //MARK: 검색
    func searchNewsletter(brandName: String) async throws -> [Newsletter]
    
    
    //MARK: 모든 뉴스레터 브랜드
    func fetchNewsletters(orderOpt: String?, industry: [Int]?, day: [Int]?) async throws -> [Brand]
    
    func fetchNewsletterBrand(id: String) async throws -> BrandDetail
    
    func pauseSubscription(newsletterId: String) async throws
    func resumeSubscription(newsletterId: String) async throws
    
    func fetchGuestAllNewsletters(orderOpt: String?, industry: [Int]?, day: [Int]?) async throws -> [Brand]
    
    func fetchGuestNewsletterBrand(id: String) async throws -> BrandDetail
    
    
}
