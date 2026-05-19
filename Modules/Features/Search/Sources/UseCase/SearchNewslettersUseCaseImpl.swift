import SearchDomain

public final class SearchNewslettersUseCaseImpl: SearchNewslettersUseCase {
    private let repository: SearchRepository

    public init(repository: SearchRepository) {
        self.repository = repository
    }

    public func execute(brandName: String) async throws -> [SearchedNewsletter] {
        try await repository.searchNewsletters(brandName: brandName)
    }
}
