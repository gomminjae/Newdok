public struct ExploreRecommendedNewsletter {
    public let union: [ExploreNewsletterDetail]
    public let intersection: [ExploreNewsletterDetail]

    public init(union: [ExploreNewsletterDetail], intersection: [ExploreNewsletterDetail]) {
        self.union = union
        self.intersection = intersection
    }
}
