import Testing
import ExploreDomain
@testable import Explore

@Suite("TransformExploreRecommendationUseCase Tests")
struct TransformExploreRecommendationUseCaseTests {
    private func interest(_ id: Int) -> ExploreInterest { ExploreInterest(id: id, name: "i\(id)") }

    private func newsletter(_ id: Int, interests: [Int] = []) -> ExploreNewsletterDetail {
        ExploreNewsletterDetail(
            id: id, brandName: "", firstDescription: "", secondDescription: "",
            publicationCycle: "", subscribeUrl: "", imageUrl: nil,
            createdAt: "", updatedAt: "", industries: [], interests: interests.map(interest)
        )
    }

    @Test("union은 관심사 매칭 수 내림차순으로 우선순위가 매겨진다")
    func prioritizesUnionByMatchCount() {
        let sut = TransformExploreRecommendationUseCaseImpl()
        // 매칭 수: id2=2, id3=1, id1=0 (서로 달라 random tiebreak 없음)
        let union = [newsletter(1, interests: []), newsletter(2, interests: [10, 11]), newsletter(3, interests: [10])]
        let response = ExploreRecommendedNewsletter(union: union, intersection: [])

        let result = sut.execute(response: response, userInterestIds: [10, 11])

        #expect(result.prioritizedUnion.map(\.id) == [2, 3, 1])
    }

    @Test("carousel은 중복 id가 없고 최대 5개다")
    func carouselDedupAndCapped() {
        let sut = TransformExploreRecommendationUseCaseImpl()
        let intersection = [newsletter(1), newsletter(1), newsletter(2)] // id 1 중복
        let union = [newsletter(3), newsletter(4), newsletter(5), newsletter(6), newsletter(7)]
        let response = ExploreRecommendedNewsletter(union: union, intersection: intersection)

        let result = sut.execute(response: response, userInterestIds: nil)

        #expect(result.carousel.count == 5)
        #expect(Set(result.carousel.map(\.id)).count == result.carousel.count) // 중복 없음
        // intersection 고유 id(1,2)는 항상 포함
        #expect(Set(result.carousel.map(\.id)).isSuperset(of: [1, 2]))
    }

    @Test("prioritizedUnion은 최대 6개로 제한된다")
    func unionCappedAtSix() {
        let sut = TransformExploreRecommendationUseCaseImpl()
        let union = (1...10).map { newsletter($0) }
        let response = ExploreRecommendedNewsletter(union: union, intersection: [])

        let result = sut.execute(response: response, userInterestIds: nil)

        #expect(result.prioritizedUnion.count == 6)
    }
}
