import Combine
import Shared
import ExploreDomain
import SwiftUI

@MainActor
public class ExploreViewModel: ObservableObject, ErrorHandling {
    @Published public var myRecommendation: [ExploreNewsletterDetail] = []
    @Published public var unionRecommendation: [ExploreNewsletterDetail] = []
    @Published public var fixedMyRecommendation: [ExploreNewsletterDetail] = []
    @Published public var fixedUnionRecommendation: [ExploreNewsletterDetail] = []

    private var cachedRecommendation: ExploreRecommendedNewsletter?
    private var lastFetchTime: Date?

    @Published public var allNewsletters: [ExploreBrand] = []

    @Published public var selectedTab: Int = 0

    @Published public var orderOpt: String? = "인기순"
    @Published public var industry: [Int]?
    @Published public var day: [Int]?

    @Published public var isShowFilterSheet: Bool = false
    @Published public var isShowSortSheet: Bool = false
    @Published public var isRecommend: Bool = false
    @Published public var shouldScrollToTop: Bool = false

    @Published public var isRefreshingRecommendation: Bool = false
    @Published public var isRefreshingAllNewsletters: Bool = false
    @Published public var currentError: AppError?

    var hasUserProfile: Bool {
        return userInfoStore.hasProfile
    }

    private let useCase: ExploreNewsletterUseCase
    private let authState: Authenticatable
    private let userInfoStore: UserInfoStorable
    private var cancellables = Set<AnyCancellable>()

    public init(
        useCase: ExploreNewsletterUseCase,
        authState: Authenticatable,
        userInfoStore: UserInfoStorable
    ) {
        self.useCase = useCase
        self.authState = authState
        self.userInfoStore = userInfoStore

        authState.authStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                if state == .guest {
                    self?.clearData()
                }
            }
            .store(in: &cancellables)
    }

    public func fetchRecommendation(forceRefresh: Bool = false) async {
        if !forceRefresh,
           let cached = cachedRecommendation,
           let lastTime = lastFetchTime,
           Date().timeIntervalSince(lastTime) < 300 {
            updateRecommendationData(from: cached)
            return
        }

        await performAsync(feature: "explore", operation: "fetchRecommendation", loadingBinding: \.isRefreshingRecommendation) {
            let response = try await useCase.fetchRecommendation()

            cachedRecommendation = response
            lastFetchTime = Date()

            updateRecommendationData(from: response)
        }
    }

    private func updateRecommendationData(from response: ExploreRecommendedNewsletter) {
        myRecommendation = response.intersection
        unionRecommendation = response.union

        let shuffledIntersection = response.intersection.shuffled()
        let prioritizedUnion = prioritizeInterests(for: response.union)

        fixedMyRecommendation = buildRecommendationCarousel(
            primary: shuffledIntersection,
            fallback: prioritizedUnion
        )
        fixedUnionRecommendation = Array(prioritizedUnion.prefix(6))
    }

    private func prioritizeInterests(for newsletters: [ExploreNewsletterDetail]) -> [ExploreNewsletterDetail] {
        guard let userInterests = userInfoStore.load()?.interestIds else {
            return newsletters.shuffled()
        }

        return newsletters.sorted { newsletter1, newsletter2 in
            let userMatchedCount1 = newsletter1.interests.filter { userInterests.contains($0.id) }.count
            let userMatchedCount2 = newsletter2.interests.filter { userInterests.contains($0.id) }.count

            if userMatchedCount1 != userMatchedCount2 {
                return userMatchedCount1 > userMatchedCount2
            }

            return Bool.random()
        }
    }

    public func prioritizeInterestsForNewsletter(_ newsletter: ExploreNewsletterDetail) -> [ExploreInterest] {
        guard let userInterests = userInfoStore.load()?.interestIds else {
            return newsletter.interests.shuffled()
        }

        let userMatchedInterests = newsletter.interests.filter { interest in
            userInterests.contains(interest.id)
        }

        let remainingInterests = newsletter.interests.filter { interest in
            !userInterests.contains(interest.id)
        }.shuffled()

        return userMatchedInterests + remainingInterests
    }

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
            let response = try await useCase.fetchNewsletters(orderOpt: orderOpt, industry: industry, day: day)
            allNewsletters = response
        }
    }

    public func fetchBrandDetail(id: String) async {
        await performAsync(feature: "explore", operation: "fetchBrandDetail") {
            _ = try await useCase.fetchNewsletterBrand(id: id)
        }
    }

    public func fetchGuestAllNewsletters() async {
        await performAsync(feature: "explore", operation: "fetchGuestAllNewsletters") {
            let response = try await useCase.fetchGuestNewsletters(orderOpt: orderOpt, industry: industry, day: day)
            allNewsletters = response
        }
    }

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

        cachedRecommendation = nil
        lastFetchTime = nil
    }
}
