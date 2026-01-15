//
//  NewsletterRepository.swift
//  Domain
//
//  Created by 권민재 on 4/18/25.
//

import Foundation
import Shared


public protocol NewsletterRepository {
    func fetchActiveSubscription() async throws -> [Newsletter]
    func fetchPausedSubscription() async throws -> [Newsletter]
    func fetchSubscriptionCount() async throws -> Int
    func fetchRecommendation() async throws -> RecommendedNewsletter
    func searchNewsletter(brandName: String) async throws -> [Newsletter]
    func fetchNewsletters(orderOpt: String?, industry: [Int]?, day: [Int]?) async throws -> [Brand]
    func fetchNewsletterBrand(id: String) async throws -> BrandDetail
    func pauseSubscription(newsletterId: String) async throws
    func resumeSubscription(newsletterId: String) async throws
    func fetchGuestAllNewsletters(orderOpt: String?, industry: [Int]?, day: [Int]?) async throws -> [Brand]
    func fetchGuestNewsletterBrand(id: String) async throws -> BrandDetail
}
