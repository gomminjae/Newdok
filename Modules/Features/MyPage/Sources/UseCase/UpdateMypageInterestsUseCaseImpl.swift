import MypageDomain

public final class UpdateMypageInterestsUseCaseImpl: UpdateMypageInterestsUseCase {
    private let repository: MypageUserRepository

    public init(repository: MypageUserRepository) {
        self.repository = repository
    }

    public func execute(_ interestIds: [Int]) async throws {
        try await repository.updateInterest(interestIds)
    }
}
