import Shared

public protocol LoadOptionsUseCase: Sendable {
    func execute() async throws
}

public final class LoadOptionsUseCaseImpl: LoadOptionsUseCase {
    private let newsletterUseCase: ExploreNewsletterUseCase

    public init(newsletterUseCase: ExploreNewsletterUseCase) {
        self.newsletterUseCase = newsletterUseCase
    }

    public func execute() async throws {
        let optionList = try await newsletterUseCase.fetchOptionList()

        let interests = optionList.interests.map { SelectableItem(id: $0.id, name: $0.name) }
        let industries = optionList.industries.map { SelectableItem(id: $0.id, name: $0.name) }
        let days = optionList.days.map { SelectableItem(id: $0.id, name: $0.name) }

        await MainActor.run {
            SelectableItemStore.shared.loadOptions(
                interests: interests,
                industries: industries,
                days: days
            )
        }
    }
}
