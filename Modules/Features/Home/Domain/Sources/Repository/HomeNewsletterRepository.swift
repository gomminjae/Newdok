import Foundation

public protocol HomeNewsletterRepository {
    func fetchActiveSubscription() async throws -> [HomeNewsletter]
}
