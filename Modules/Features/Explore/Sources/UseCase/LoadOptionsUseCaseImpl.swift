import Shared
import ExploreDomain

public final class LoadOptionsUseCaseImpl: LoadOptionsUseCase {
    private let repository: ExploreNewsletterRepository

    public init(repository: ExploreNewsletterRepository) {
        self.repository = repository
    }

    public func execute() async throws {
        let optionList = try await repository.fetchOptionList()

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
