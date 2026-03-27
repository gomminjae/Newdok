public protocol SubscribeNewsletterRepository {
    func fetchActiveSubscription() async throws -> [SubscribeNewsletter]
    func fetchPausedSubscription() async throws -> [SubscribeNewsletter]
    func pauseSubscription(newsletterId: String) async throws
    func resumeSubscription(newsletterId: String) async throws
    func fetchSubscriptionCount() async throws -> Int
}
