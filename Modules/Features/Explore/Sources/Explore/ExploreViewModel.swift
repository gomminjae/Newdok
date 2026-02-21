//
//  Explore ViewModel.swift
//  Explore
//
//  Created by 권민재 on 4/24/25.
//  Copyright © 2025 Newdok. All rights reserved.
//
import Combine
import Shared
import Domain
import SwiftUI

@MainActor
public class ExploreViewModel: ObservableObject {
    @Published public var myRecommendation: [NewsletterDetail] = []
    @Published public var unionRecommendation: [NewsletterDetail] = []
    @Published public var fixedMyRecommendation: [NewsletterDetail] = []
    @Published public var fixedUnionRecommendation: [NewsletterDetail] = []
    
    // 캐시된 데이터 (메모리 최적화)
    private var cachedRecommendation: RecommendedNewsletter?
    private var lastFetchTime: Date?

    @Published public var allNewsletters: [Brand] = []

    // 현재 선택된 탭 (0: 추천, 1: 전체)
    @Published public var selectedTab: Int = 0
    
    @Published public var orderOpt: String? = "인기순"
    @Published public var industry: [Int]?
    @Published public var day: [Int]?
    
    @Published public var isShowFilterSheet: Bool = false
    @Published public var isShowSortSheet: Bool = false
    @Published public var isRecommend: Bool = false
    @Published public var shouldScrollToTop: Bool = false
    
    // 로딩 상태 관리
    @Published public var isRefreshingRecommendation: Bool = false
    @Published public var isRefreshingAllNewsletters: Bool = false
    
    var hasUserProfile: Bool {
        return UserInfoStore.shared.hasProfile
    }
    
    private let useCase: NewsletterUseCase
    private var cancellables = Set<AnyCancellable>()
    
    public init(useCase: NewsletterUseCase) {
        self.useCase = useCase
        
        // AppState 구독
        AppState.shared.$authState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] authState in
                if authState == .guest {
                    self?.clearData()
                }
            }
            .store(in: &cancellables)
    }
    
    public func fetchRecommendation(forceRefresh: Bool = false) async {
        // 캐시된 데이터가 있고 5분 이내라면 캐시 사용 (강제 새로고침 제외)
        if !forceRefresh,
           let cached = cachedRecommendation,
           let lastTime = lastFetchTime,
           Date().timeIntervalSince(lastTime) < 300 { // 5분 캐시
            updateRecommendationData(from: cached)
            return
        }
        
        isRefreshingRecommendation = true
        defer { isRefreshingRecommendation = false }
        
        do {
            let response = try await useCase.fetchRecommendation()
            
            // 캐시 업데이트
            cachedRecommendation = response
            lastFetchTime = Date()
            
            updateRecommendationData(from: response)
        } catch {
            isRecommend = false
        }
    }
    
    private func updateRecommendationData(from response: RecommendedNewsletter) {
        myRecommendation = response.intersection
        unionRecommendation = response.union
        
        // 교집합도 랜덤하게 섞어서 5개 선택 (매번 다른 추천을 위해)
        let shuffledIntersection = response.intersection.shuffled()
        
        // 사용자 관심사 우선순위로 정렬된 union 추천
        let prioritizedUnion = prioritizeInterests(for: response.union)
        
        fixedMyRecommendation = buildRecommendationCarousel(
            primary: shuffledIntersection,
            fallback: prioritizedUnion
        )
        fixedUnionRecommendation = Array(prioritizedUnion.prefix(6))
    }
    
    // 사용자 관심사 우선순위로 뉴스레터 정렬
    private func prioritizeInterests(for newsletters: [NewsletterDetail]) -> [NewsletterDetail] {
        guard let userInterests = UserInfoStore.shared.load()?.interestIds else {
            // 사용자 관심사가 없으면 랜덤하게 섞어서 반환
            return newsletters.shuffled()
        }
        
        return newsletters.sorted { newsletter1, newsletter2 in
            let userMatchedCount1 = newsletter1.interests.filter { userInterests.contains($0.id) }.count
            let userMatchedCount2 = newsletter2.interests.filter { userInterests.contains($0.id) }.count
            
            // 사용자 관심사 매칭 개수가 많은 순으로 정렬
            if userMatchedCount1 != userMatchedCount2 {
                return userMatchedCount1 > userMatchedCount2
            }
            
            // 매칭 개수가 같으면 랜덤하게
            return Bool.random()
        }
    }
    
    // 뉴스레터의 관심사를 사용자 관심사 우선순위로 정렬
    public func prioritizeInterestsForNewsletter(_ newsletter: NewsletterDetail) -> [Interest] {
        guard let userInterests = UserInfoStore.shared.load()?.interestIds else {
            // 사용자 관심사가 없으면 랜덤하게 섞어서 반환
            return newsletter.interests.shuffled()
        }
        
        // 사용자가 선택한 관심사와 매칭되는 것들을 우선순위로
        let userMatchedInterests = newsletter.interests.filter { interest in
            userInterests.contains(interest.id)
        }
        
        // 사용자 관심사와 매칭되지 않는 것들
        let remainingInterests = newsletter.interests.filter { interest in
            !userInterests.contains(interest.id)
        }.shuffled()
        
        // 사용자 관심사 우선 + 나머지 랜덤
        return userMatchedInterests + remainingInterests
    }
    
    // 원형큐처럼 무한 스크롤을 위한 추천 데이터 생성 (5개 유지)
    private func buildRecommendationCarousel(
        primary: [NewsletterDetail],
        fallback: [NewsletterDetail]
    ) -> [NewsletterDetail] {
        var uniqueRecommendations: [NewsletterDetail] = []
        var seenIDs = Set<Int>()
        
        func appendIfNeeded(_ detail: NewsletterDetail) {
            guard !seenIDs.contains(detail.id) else { return }
            seenIDs.insert(detail.id)
            uniqueRecommendations.append(detail)
        }
        
        primary.forEach { appendIfNeeded($0) }
        
        if uniqueRecommendations.count < 5 {
            for detail in fallback {
                guard uniqueRecommendations.count < 5 else { break }
                appendIfNeeded(detail)
            }
        }
        
        return uniqueRecommendations
    }
    
    public func fetchAllNewsletters() async {
        isRefreshingAllNewsletters = true
        defer { isRefreshingAllNewsletters = false }

        do {
            let response = try await useCase.fetchNewsletters(orderOpt: orderOpt, industry: industry, day: day)
            allNewsletters = response
        } catch {
        }
    }
    
    public func fetchBrandDetail(id: String) async {
        do {
            _ = try await useCase.fetchNewsletterBrand(id: id)
        } catch {
        }
    }
    
    public func fetchGuestAllNewsletters() async {
        do {
            let response = try await useCase.fetchGuestNewsletters(orderOpt: orderOpt, industry: industry, day: day)
            allNewsletters = response
        } catch {
        }
    }
    
    // 로그아웃 시 데이터 초기화
    private func clearData() {
        myRecommendation = []
        unionRecommendation = []
        fixedMyRecommendation = []
        fixedUnionRecommendation = []
        allNewsletters = []
        selectedTab = 0
        orderOpt = "인기순"
        industry = nil
        day = nil
        isShowFilterSheet = false
        isShowSortSheet = false
        isRecommend = false
        shouldScrollToTop = false
        
        // 캐시도 초기화
        cachedRecommendation = nil
        lastFetchTime = nil
    }
}
