import Testing
import ExploreDomain
@testable import Explore

@Suite("PrioritizeInterestsUseCase Tests")
struct PrioritizeInterestsUseCaseTests {
    private func interest(_ id: Int) -> ExploreInterest { ExploreInterest(id: id, name: "i\(id)") }

    private func newsletter(interests: [ExploreInterest]) -> ExploreNewsletterDetail {
        ExploreNewsletterDetail(
            id: 1, brandName: "", firstDescription: "", secondDescription: "",
            publicationCycle: "", subscribeUrl: "", imageUrl: nil,
            createdAt: "", updatedAt: "", industries: [], interests: interests
        )
    }

    @Test("매칭된 관심사가 원래 순서를 유지한 채 앞으로 온다")
    func matchedInterestsComeFirst() {
        let sut = PrioritizeInterestsUseCaseImpl()
        let nl = newsletter(interests: [interest(1), interest(2), interest(3), interest(4)])

        let result = sut.execute(newsletter: nl, userInterestIds: [3, 1])

        // 매칭(1,3)이 앞 2개 — filter는 원래 순서 보존이므로 [1, 3]
        #expect(Array(result.prefix(2)).map(\.id) == [1, 3])
        // 손실 없이 전체 보존
        #expect(Set(result.map(\.id)) == Set([1, 2, 3, 4]))
        #expect(result.count == 4)
    }

    @Test("userInterestIds가 없으면 전체 관심사를 그대로 반환한다")
    func noUserInterestsReturnsAll() {
        let sut = PrioritizeInterestsUseCaseImpl()
        let nl = newsletter(interests: [interest(1), interest(2)])

        #expect(Set(sut.execute(newsletter: nl, userInterestIds: nil).map(\.id)) == Set([1, 2]))
        #expect(Set(sut.execute(newsletter: nl, userInterestIds: []).map(\.id)) == Set([1, 2]))
    }
}
