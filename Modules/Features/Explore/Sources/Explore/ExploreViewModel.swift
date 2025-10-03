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
    @Published public var industry: [Int]? = nil
    @Published public var day: [Int]? = nil
    
    
    
    
    @Published public var isShowFilterSheet: Bool = false
    @Published public var isShowSortSheet: Bool = false
    @Published public var isRecommend: Bool = false
    @Published public var shouldScrollToTop: Bool = false
    
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
            
            print("🔄 [ExploreViewModel] 캐시된 추천 데이터 사용")
            updateRecommendationData(from: cached)
            return
        }
        
        do {
            let response = try await useCase.fetchRecommendation()
            
            // 캐시 업데이트
            cachedRecommendation = response
            lastFetchTime = Date()
            
            print("🔄 [ExploreViewModel] fetchRecommendation 성공:")
            print("  - intersection count: \(response.intersection.count)")
            print("  - union count: \(response.union.count)")
            
            updateRecommendationData(from: response)
            
        } catch {
            print("❌ [ExploreViewModel] 추천 에러:", error)
            isRecommend = false
        }
    }
    
    private func updateRecommendationData(from response: RecommendedNewsletter) {
        myRecommendation = response.intersection
        unionRecommendation = response.union
        
        // 교집합도 랜덤하게 섞어서 5개 선택 (매번 다른 추천을 위해)
        let shuffledIntersection = response.intersection.shuffled()
        fixedMyRecommendation = createCircularRecommendation(from: shuffledIntersection)
        
        // 사용자 관심사 우선순위로 정렬된 union 추천
        let prioritizedUnion = prioritizeInterests(for: response.union)
        fixedUnionRecommendation = Array(prioritizedUnion.prefix(6))
        
        print("  - fixedMyRecommendation count: \(fixedMyRecommendation.count)")
        print("  - fixedUnionRecommendation count: \(fixedUnionRecommendation.count)")
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
    private func createCircularRecommendation(from items: [NewsletterDetail]) -> [NewsletterDetail] {
        guard !items.isEmpty else { return [] }
        
        // 5개 미만이면 복사해서 5개로 늘리기
        if items.count < 5 {
            var expandedItems: [NewsletterDetail] = []
            for i in 0..<5 {
                let sourceIndex = i % items.count
                expandedItems.append(items[sourceIndex])
            }
            return expandedItems
        }
        
        // 5개 이상이면 5개만 반환
        return Array(items.prefix(5))
    }
    
    public func fetchAllNewsletters() async {
        do {
            print("🔍 [ExploreViewModel] fetchAllNewsletters 호출:")
            print("  - orderOpt: \(orderOpt ?? "nil")")
            print("  - industry: \(industry ?? [])")
            print("  - day: \(day ?? [])")
            
            let response = try await useCase.fetchNewsletters(orderOpt: orderOpt, industry: industry, day: day)
            allNewsletters = response
            
            print("✅ [ExploreViewModel] 데이터 로딩 완료: \(response.count)개")
        } catch {
            print("❌ [ExploreViewModel] 모든 뉴스레터 에러:", error)
        }
    }
    
    public func fetchBrandDetail(id: String) async {
        do {
            _ = try await useCase.fetchNewsletterBrand(id: id)
        } catch {
            print("❌ [ExploreViewModel] 브랜드 상세 에러:", error)
        }
    }
    
    public func fetchGuestAllNewsletters() async {
        do {
            let response = try await useCase.fetchGuestNewsletters(orderOpt: orderOpt, industry: industry, day: day)
            allNewsletters = response
        } catch {
            print("비회원 조회 실패")
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
