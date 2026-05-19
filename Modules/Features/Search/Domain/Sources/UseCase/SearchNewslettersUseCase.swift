import Foundation

public protocol SearchNewslettersUseCase: Sendable {
    func execute(brandName: String) async throws -> [SearchedNewsletter]
}
