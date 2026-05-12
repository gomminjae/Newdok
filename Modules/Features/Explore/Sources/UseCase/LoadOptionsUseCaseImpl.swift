import Shared
import ExploreDomain

public final class LoadOptionsUseCaseImpl: LoadOptionsUseCase {
    private let repository: ExploreNewsletterRepository
    private let selectableItemStore: SelectableItemStoreProtocol

    public init(
        repository: ExploreNewsletterRepository,
        selectableItemStore: SelectableItemStoreProtocol
    ) {
        self.repository = repository
        self.selectableItemStore = selectableItemStore
    }

    public func execute() async throws {
        let optionList = try await repository.fetchOptionList()

        let interests = optionList.interests.map { SelectableItem(id: $0.id, name: $0.name) }
        let industries = optionList.industries.map { SelectableItem(id: $0.id, name: $0.name) }
        let days = optionList.days.map { SelectableItem(id: $0.id, name: $0.name) }

        await MainActor.run {
            selectableItemStore.loadOptions(
                interests: interests,
                industries: industries,
                days: days
            )
        }
    }
}
