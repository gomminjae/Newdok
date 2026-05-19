import MypageDomain

public final class UpdateMypageIndustryUseCaseImpl: UpdateMypageIndustryUseCase {
    private let repository: MypageUserRepository

    public init(repository: MypageUserRepository) {
        self.repository = repository
    }

    public func execute(_ industryId: Int) async throws {
        try await repository.updateIndustry(industryId)
    }
}
