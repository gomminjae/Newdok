import Foundation

public protocol FetchHomeNewslettersUseCase: Sendable {
    func execute() async throws -> [HomeNewsletter]
}
