import Foundation

public protocol RefreshHomeArticlesUseCase: Sendable {
    func execute() async throws
}
