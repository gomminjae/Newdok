import MypageDomain

public final class CheckMypageIDDupUseCaseImpl: CheckMypageIDDupUseCase {
    private let repository: MypageUserRepository

    public init(repository: MypageUserRepository) {
        self.repository = repository
    }

    public func execute(_ loginId: String) async throws -> MypageIDCheckResult {
        try await repository.checkIDDup(loginId)
    }
}
