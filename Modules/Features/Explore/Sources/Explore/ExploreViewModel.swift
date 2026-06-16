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

    public var orderOpt: ExploreOrderOption = .popular
    public var industry: [Int]?
    public var day: [Int]?

    public var isShowFilterSheet: Bool = false
    public var isShowSortSheet: Bool = false
    public var isRecommend: Bool = false
    public var shouldScrollToTop: Bool = false

    // 로딩 상태 관리
    public var isRefreshingRecommendation: Bool = false
    public var isRefreshingAllNewsletters: Bool = false
    public var isInitialLoaded: Bool = false
    public var currentError: AppError?

    public var nickname: String = ""

    private var isGuest: Bool { appState.authState == .guest }

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
        orderOpt = .popular
        shouldScrollToTop = true
    }

    private let fetchNewslettersUseCase: FetchExploreNewslettersUseCase
    private let fetchGuestNewslettersUseCase: FetchGuestExploreNewslettersUseCase
    private let fetchRecommendationUseCase: FetchExploreRecommendationUseCase
    private let transformRecommendationUseCase: TransformExploreRecommendationUseCase
    private let prioritizeInterestsUseCase: PrioritizeInterestsUseCase
    private let userInfoStore: UserInfoStoreProtocol
    private let selectableItemStore: SelectableItemStoreProtocol
    private let appState: AppState

    public init(
        fetchNewslettersUseCase: FetchExploreNewslettersUseCase,
        fetchGuestNewslettersUseCase: FetchGuestExploreNewslettersUseCase,
        fetchRecommendationUseCase: FetchExploreRecommendationUseCase,
        transformRecommendationUseCase: TransformExploreRecommendationUseCase,
        prioritizeInterestsUseCase: PrioritizeInterestsUseCase,
        userInfoStore: UserInfoStoreProtocol,
        selectableItemStore: SelectableItemStoreProtocol,
        appState: AppState = .shared
    ) {
        self.fetchNewslettersUseCase = fetchNewslettersUseCase
        self.fetchGuestNewslettersUseCase = fetchGuestNewslettersUseCase
        self.fetchRecommendationUseCase = fetchRecommendationUseCase
        self.transformRecommendationUseCase = transformRecommendationUseCase
        self.prioritizeInterestsUseCase = prioritizeInterestsUseCase
        self.userInfoStore = userInfoStore
        self.selectableItemStore = selectableItemStore
        self.appState = appState
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

        let userInterestIds = userInfoStore.load()?.interestIds
        let result = transformRecommendationUseCase.execute(response: response, userInterestIds: userInterestIds)
        fixedMyRecommendation = result.carousel
        fixedUnionRecommendation = result.prioritizedUnion
    }

    public func prioritizeInterestsForNewsletter(_ newsletter: ExploreNewsletterDetail) -> [ExploreInterest] {
        let userInterestIds = userInfoStore.load()?.interestIds
        return prioritizeInterestsUseCase.execute(newsletter: newsletter, userInterestIds: userInterestIds)
    }

    public func fetchAllNewsletters() async {
        await performAsync(feature: "explore", operation: "fetchAllNewsletters", loadingBinding: \.isRefreshingAllNewsletters) {
            let response = try await fetchNewslettersUseCase.execute(orderOpt: orderOpt, industry: industry, day: day)
            allNewsletters = response
        }
    }

    public func fetchGuestAllNewsletters() async {
        await performAsync(feature: "explore", operation: "fetchGuestAllNewsletters") {
            let response = try await fetchGuestNewslettersUseCase.execute(orderOpt: orderOpt, industry: industry, day: day)
            allNewsletters = response
        }
    }

    public func loadInitial() async {
        if isGuest {
            await fetchGuestAllNewsletters()
            isInitialLoaded = true
        } else {
            await fetchRecommendation()
            isInitialLoaded = true
            await fetchAllNewsletters()
        }
    }

    public func reloadOnAuthChanged() async {
        clearData()
        reloadUserInfo()
        if isGuest {
            await fetchGuestAllNewsletters()
        } else {
            await fetchRecommendation()
            await fetchAllNewsletters()
        }
        isInitialLoaded = true
    }

    public func reloadOnTrigger() async {
        if isGuest {
            await fetchGuestAllNewsletters()
        } else {
            await fetchRecommendation()
            await fetchAllNewsletters()
        }
    }

    public func retryLoad() async {
        if isGuest {
            await fetchGuestAllNewsletters()
        } else {
            await fetchRecommendation()
            await fetchAllNewsletters()
        }
    }

    public func handleSort() async {
        shouldScrollToTop = true
        await fetchCurrentNewsletters()
    }

    public func handleFilter() async {
        shouldScrollToTop = true
        await fetchCurrentNewsletters()
    }

    public func handleReset() async {
        await resetFilters()
        await fetchCurrentNewsletters()
    }

    private func fetchCurrentNewsletters() async {
        if isGuest {
            await fetchGuestAllNewsletters()
        } else {
            await fetchAllNewsletters()
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
        orderOpt = .popular
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
