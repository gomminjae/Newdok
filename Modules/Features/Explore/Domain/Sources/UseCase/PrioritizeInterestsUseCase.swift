public protocol PrioritizeInterestsUseCase: Sendable {
    func execute(newsletter: ExploreNewsletterDetail, userInterestIds: [Int]?) -> [ExploreInterest]
}
