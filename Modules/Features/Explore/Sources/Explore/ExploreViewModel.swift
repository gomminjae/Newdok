//
//  Explore ViewModel.swift
//  Explore
//
//  Created by 권민재 on 4/24/25.
//  Copyright © 2025 Newdok. All rights reserved.
//
import Shared
import ExploreDomain
import ExploreInterface
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
    private var userInfo: UserInfo?
    private var recommendationRequestID: UUID?

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

    private(set) var hasUserProfile = false

    public func reloadUserInfo() {
        let latestUserInfo = userInfoStore.load()
        if userInfo != latestUserInfo {
            cachedRecommendation = nil
            lastFetchTime = nil
            recommendationRequestID = nil
            isRefreshingRecommendation = false
            myRecommendation = []
            unionRecommendation = []
            fixedMyRecommendation = []
            fixedUnionRecommendation = []
            isInitialLoaded = false
            currentError = nil
        }
        userInfo = latestUserInfo
        nickname = latestUserInfo?.nickname ?? ""
        hasUserProfile = userInfoStore.hasProfile
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
        reloadUserInfo()
    }

    var industries: [SelectableItem] {
        selectableItemStore.list(for: .industry)
    }

    var days: [SelectableItem] {
        selectableItemStore.list(for: .day)
    }

    public func fetchRecommendation(forceRefresh: Bool = false) async {
        guard !Task.isCancelled else { return }
        reloadUserInfo()
        // 캐시된 데이터가 있고 5분 이내라면 캐시 사용 (강제 새로고침 제외)
        if !forceRefresh,
           let cached = cachedRecommendation,
           let lastTime = lastFetchTime,
           Date().timeIntervalSince(lastTime) < 300 { // 5분 캐시
            updateRecommendationData(from: cached)
            return
        }

        let requestID = UUID()
        let requestedUserInfo = userInfo
        recommendationRequestID = requestID
        isRefreshingRecommendation = true
        defer {
            if recommendationRequestID == requestID {
                isRefreshingRecommendation = false
                recommendationRequestID = nil
            }
        }

        do {
            let response = try await fetchRecommendationUseCase.execute()
            try Task.checkCancellation()
            guard recommendationRequestID == requestID,
                  requestedUserInfo == userInfoStore.load() else { return }

            // 캐시 업데이트
            cachedRecommendation = response
            lastFetchTime = Date()

            updateRecommendationData(from: response)
            currentError = nil
        } catch {
            guard !Task.isCancelled,
                  recommendationRequestID == requestID,
                  requestedUserInfo == userInfoStore.load() else { return }
            handleError(error, feature: "explore", operation: "fetchRecommendation")
        }
    }

    private func updateRecommendationData(from response: ExploreRecommendedNewsletter) {
        myRecommendation = response.intersection
        unionRecommendation = response.union

        let userInterestIds = userInfoStore.load()?.interestIds
        let result = transformRecommendationUseCase.execute(response: response, userInterestIds: userInterestIds)
        fixedMyRecommendation = result.carousel
        fixedUnionRecommendation = result.prioritizedUnion
        isInitialLoaded = true
    }

    public func prioritizeInterestsForNewsletter(_ newsletter: ExploreNewsletterDetail) -> [ExploreInterest] {
        let userInterestIds = userInfoStore.load()?.interestIds
        return prioritizeInterestsUseCase.execute(newsletter: newsletter, userInterestIds: userInterestIds)
    }

    public func fetchAllNewsletters() async {
        await performAsync(feature: "explore", operation: "fetchAllNewsletters", loadingBinding: \.isRefreshingAllNewsletters) {
            let response = try await fetchNewslettersUseCase.execute(orderOpt: orderOpt, industry: industry, day: day)
            try Task.checkCancellation()
            allNewsletters = response
        }
    }

    public func fetchGuestAllNewsletters() async {
        await performAsync(feature: "explore", operation: "fetchGuestAllNewsletters") {
            let response = try await fetchGuestNewslettersUseCase.execute(orderOpt: orderOpt, industry: industry, day: day)
            try Task.checkCancellation()
            allNewsletters = response
        }
    }

    public func loadInitial() async {
        reloadUserInfo()
        if isGuest {
            await fetchGuestAllNewsletters()
            isInitialLoaded = true
        } else {
            await fetchRecommendation()
            guard !Task.isCancelled else { return }
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

    public func activate(_ landing: ExploreLanding) async {
        orderOpt = .popular
        industry = nil
        isShowFilterSheet = false
        isShowSortSheet = false
        shouldScrollToTop = true

        switch landing {
        case .recommendations:
            selectedTab = isGuest ? 1 : 0
            day = nil
        case let .allNewsletters(selectedDay):
            selectedTab = isGuest ? 0 : 1
            day = selectedDay.map { [$0] }
        }

        await reloadOnTrigger()
        guard !Task.isCancelled else { return }
        isInitialLoaded = true
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
        recommendationRequestID = nil
        isRefreshingRecommendation = false
        isInitialLoaded = false
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
