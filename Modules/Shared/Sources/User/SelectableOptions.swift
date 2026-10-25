import Foundation

public struct SelectableOptions: Equatable, Sendable {
    public let interests: [SelectableItem]
    public let industries: [SelectableItem]
    public let days: [SelectableItem]

    public init(interests: [SelectableItem], industries: [SelectableItem], days: [SelectableItem]) {
        self.interests = interests
        self.industries = industries
        self.days = days
    }
}

public enum SelectableOptionsLoadState: Equatable, Sendable {
    case idle
    case loading
    case loaded
    case failed
}

public protocol FetchSelectableOptionsUseCase: Sendable {
    func execute() async throws -> SelectableOptions
}
