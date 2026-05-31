import Testing
import Foundation
import Shared
@testable import Explore
@testable import ExploreTesting
@testable import ExploreDomain

private final class StubUserInfoStore: UserInfoStoreProtocol, @unchecked Sendable {
    var storedUser: UserInfo?
    func save(_ user: UserInfo) { storedUser = user }
    func load() -> UserInfo? { storedUser }
    func clear() { storedUser = nil }
    var hasProfile: Bool { storedUser?.industryId != nil }
}

private final class StubSelectableItemStore: SelectableItemStoreProtocol, @unchecked Sendable {
    var interests: [SelectableItem] { [] }
    var industries: [SelectableItem] { [] }
    var days: [SelectableItem] { [] }
    func loadOptions(interests: [SelectableItem], industries: [SelectableItem], days: [SelectableItem]) {}
    func list(for category: SelectableCategoryType) -> [SelectableItem] { [] }
    func name(for id: Int, in category: SelectableCategoryType) -> String { "" }
    func id(for name: String, in category: SelectableCategoryType) -> Int? { nil }
}

@Suite("ExploreViewModel Tests")
@MainActor
struct ExploreViewModelTests {
    private func makeSUT() -> (
        vm: ExploreViewModel,
        fetchNewsletters: MockFetchExploreNewslettersUseCase,
        fetchBrandDetail: MockFetchExploreBrandDetailUseCase,
        fetchGuest: MockFetchGuestExploreNewslettersUseCase,
        fetchRecommendation: MockFetchExploreRecommendationUseCase
    ) {
        let fetchNewsletters = MockFetchExploreNewslettersUseCase()
        let fetchBrandDetail = MockFetchExploreBrandDetailUseCase()
        let fetchGuest = MockFetchGuestExploreNewslettersUseCase()
        let fetchRecommendation = MockFetchExploreRecommendationUseCase()
        let vm = ExploreViewModel(
            fetchNewslettersUseCase: fetchNewsletters,
            fetchBrandDetailUseCase: fetchBrandDetail,
            fetchGuestNewslettersUseCase: fetchGuest,
            fetchRecommendationUseCase: fetchRecommendation,
            transformRecommendationUseCase: MockTransformExploreRecommendationUseCase(),
            userInfoStore: StubUserInfoStore(),
            selectableItemStore: StubSelectableItemStore()
        )
        return (vm, fetchNewsletters, fetchBrandDetail, fetchGuest, fetchRecommendation)
    }

    @Test func fetchAllNewsletters_success() async {
        let (vm, fetchNewsletters, _, _, _) = makeSUT()
        let brands = [
            ExploreBrand(brandId: 1, brandName: "뉴스레터A", imageUrl: nil, interests: [], isSubscribed: nil, shortDescription: "설명", subscriptionCount: 100)
        ]
        fetchNewsletters.result = .success(brands)

        await vm.fetchAllNewsletters()

        #expect(fetchNewsletters.executeCallCount == 1)
        #expect(vm.allNewsletters.count == 1)
        #expect(vm.allNewsletters.first?.brandName == "뉴스레터A")
    }

    @Test func fetchAllNewsletters_failure() async {
        let (vm, fetchNewsletters, _, _, _) = makeSUT()
        fetchNewsletters.result = .failure(NSError(domain: "test", code: -1))

        await vm.fetchAllNewsletters()

        #expect(vm.allNewsletters.isEmpty)
    }

    @Test func fetchGuestAllNewsletters_success() async {
        let (vm, _, _, fetchGuest, _) = makeSUT()
        let brands = [
            ExploreBrand(brandId: 2, brandName: "게스트B", imageUrl: nil, interests: [], isSubscribed: nil, shortDescription: "설명", subscriptionCount: 50)
        ]
        fetchGuest.result = .success(brands)

        await vm.fetchGuestAllNewsletters()

        #expect(fetchGuest.executeCallCount == 1)
        #expect(vm.allNewsletters.count == 1)
    }

    @Test func fetchRecommendation_success() async {
        let (vm, _, _, _, fetchRecommendation) = makeSUT()
        let recommendation = ExploreRecommendedNewsletter(union: [], intersection: [])
        fetchRecommendation.result = .success(recommendation)

        await vm.fetchRecommendation(forceRefresh: true)

        #expect(fetchRecommendation.executeCallCount == 1)
    }

    @Test func resetFilters_clearsState() async {
        let (vm, _, _, _, _) = makeSUT()
        vm.day = [1, 2]
        vm.industry = [3]
        vm.orderOpt = .newest

        await vm.resetFilters()

        #expect(vm.day == nil)
        #expect(vm.industry == nil)
        #expect(vm.orderOpt == .popular)
        #expect(vm.shouldScrollToTop == true)
    }

    @Test func clearData_resetsAllState() {
        let (vm, _, _, _, _) = makeSUT()
        vm.allNewsletters = [ExploreBrand(brandId: 1, brandName: "A", imageUrl: nil, interests: [], isSubscribed: nil, shortDescription: "", subscriptionCount: 0)]
        vm.selectedTab = 1

        vm.clearData()

        #expect(vm.allNewsletters.isEmpty)
        #expect(vm.selectedTab == 0)
        #expect(vm.orderOpt == .popular)
    }
}
