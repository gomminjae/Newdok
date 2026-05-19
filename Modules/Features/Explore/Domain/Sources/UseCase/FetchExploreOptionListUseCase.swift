import Foundation

public protocol FetchExploreOptionListUseCase: Sendable {
    func execute() async throws -> ExploreOptionList
}
