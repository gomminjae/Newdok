//
//  Explore ViewModel.swift
//  Explore
//
//  Created by 권민재 on 4/24/25.
//  Copyright © 2025 Newdok. All rights reserved.
//
import Shared
import ExploreDomain
import SwiftUI
import Observation

@Observable
@MainActor
public final class ExploreViewModel: ErrorHandling {
    public var myRecommendation: [ExploreNewsletterDetail] = []
    public var unionRecommendation: [ExploreNewsletterDetail] = []
    public var fixedMyRecommendation: [ExploreNewsletterDetail] = []
    public var fixedUnionRecommendation: [ExploreNewsletterDetail] = []

    // 캐시된 데이터 (메모리 최적화)
    private var cachedRecommendation: ExploreRecommendedNewsletter?
    private var lastFetchTime: Date?

    public var allNewsletters: [ExploreBrand] = []

    // 현재 선택된 탭 (0: 추천, 1: 전체)
    public var selectedTab: Int = 0

    public var orderOpt: String? = "인기순"
    public var industry: [Int]?
    public var day: [Int]?

    public var isShowFilterSheet: Bool = false
    public var isShowSortSheet: Bool = false
    public var isRecommend: Bool = false
    public var shouldScrollToTop: Bool = false

    // 로딩 상태 관리
    public var isRefreshingRecommendation: Bool = false
    public var isRefreshingAllNewsletters: Bool = false
    public var currentError: AppError?

    public var nickname: String = ""

    var hasUserProfile: Bool {
        return userInfoStore.hasProfile
    }

    public func reloadUserInfo() {
        nickname = userInfoStore.load()?.nickname ?? ""
    }

    public var industryText: String {
        guard let selected = industry else { return "산업" }
        if selected.count == 1 {
            let name = selectableItemStore.name(for: selected.first!, in: .industry)
            return name.isEmpty ? "산업" : name
        }
        return "산업 \(selected.count)"
    }

    public var dayText: String {
        guard let selected = day else { return "발행요일" }
        if selected.count == 1 {
            let name = selectableItemStore.name(for: selected.first!, in: .day)
            return name.isEmpty ? "발행요일" : name
        }
        return "발행요일 \(selected.count)"
    }

    public func resetFilters() async {
        day = nil
        industry = nil
        orderOpt = "인기순"
        shouldScrollToTop = true
    }

    private let fetchNewslettersUseCase: FetchExploreNewslettersUseCase
    private let fetchBrandDetailUseCase: FetchExploreBrandDetailUseCase
    private let fetchGuestNewslettersUseCase: FetchGuestExploreNewslettersUseCase
    private let fetchRecommendationUseCase: FetchExploreRecommendationUseCase
    private let userInfoStore: UserInfoStoreProtocol
    private let selectableItemStore: SelectableItemStoreProtocol

    public init(
        fetchNewslettersUseCase: FetchExploreNewslettersUseCase,
        fetchBrandDetailUseCase: FetchExploreBrandDetailUseCase,
        fetchGuestNewslettersUseCase: FetchGuestExploreNewslettersUseCase,
        fetchRecommendationUseCase: FetchExploreRecommendationUseCase,
        userInfoStore: UserInfoStoreProtocol = UserInfoStore.shared,
        selectableItemStore: SelectableItemStoreProtocol = SelectableItemStore.shared
    ) {
        self.fetchNewslettersUseCase = fetchNewslettersUseCase
        self.fetchBrandDetailUseCase = fetchBrandDetailUseCase
        self.fetchGuestNewslettersUseCase = fetchGuestNewslettersUseCase
        self.fetchRecommendationUseCase = fetchRecommendationUseCase
        self.userInfoStore = userInfoStore
        self.selectableItemStore = selectableItemStore
        self.nickname = userInfoStore.load()?.nickname ?? ""
    }

    var industries: [SelectableItem] {
        selectableItemStore.list(for: .industry)
    }

    var days: [SelectableItem] {
        selectableItemStore.list(for: .day)
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

        await performAsync(feature: "explore", operation: "fetchRecommendation", loadingBinding: \.isRefreshingRecommendation) {
            let response = try await fetchRecommendationUseCase.execute()

            // 캐시 업데이트
            cachedRecommendation = response
            lastFetchTime = Date()

            updateRecommendationData(from: response)
        }
    }

    private func updateRecommendationData(from response: ExploreRecommendedNewsletter) {
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
    private func prioritizeInterests(for newsletters: [ExploreNewsletterDetail]) -> [ExploreNewsletterDetail] {
        guard let userInterests = userInfoStore.load()?.interestIds else {
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
    public func prioritizeInterestsForNewsletter(_ newsletter: ExploreNewsletterDetail) -> [ExploreInterest] {
        guard let userInterests = userInfoStore.load()?.interestIds else {
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
        primary: [ExploreNewsletterDetail],
        fallback: [ExploreNewsletterDetail]
    ) -> [ExploreNewsletterDetail] {
        var uniqueRecommendations: [ExploreNewsletterDetail] = []
        var seenIDs = Set<Int>()

        func appendIfNeeded(_ detail: ExploreNewsletterDetail) {
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
        await performAsync(feature: "explore", operation: "fetchAllNewsletters", loadingBinding: \.isRefreshingAllNewsletters) {
            let response = try await fetchNewslettersUseCase.execute(orderOpt: orderOpt, industry: industry, day: day)
            allNewsletters = response
        }
    }

    public func fetchBrandDetail(id: String) async {
        await performAsync(feature: "explore", operation: "fetchBrandDetail") {
            _ = try await fetchBrandDetailUseCase.execute(id: id)
        }
    }

    public func fetchGuestAllNewsletters() async {
        await performAsync(feature: "explore", operation: "fetchGuestAllNewsletters") {
            let response = try await fetchGuestNewslettersUseCase.execute(orderOpt: orderOpt, industry: industry, day: day)
            allNewsletters = response
        }
    }

    // 로그아웃 시 데이터 초기화
    func clearData() {
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
