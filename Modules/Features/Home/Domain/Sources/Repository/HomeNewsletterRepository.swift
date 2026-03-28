import Foundation

public protocol HomeNewsletterRepository: Sendable {
    func fetchActiveSubscription() async throws -> [HomeNewsletter]
}
