import MypageDomain

public final class MypageWithdrawUseCaseImpl: MypageWithdrawUseCase {
    private let repository: MypageUserRepository

    public init(repository: MypageUserRepository) {
        self.repository = repository
    }

    public func execute() async throws {
        try await repository.withdraw()
    }
}
