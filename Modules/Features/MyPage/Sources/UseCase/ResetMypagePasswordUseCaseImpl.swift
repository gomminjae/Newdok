import MypageDomain

public final class ResetMypagePasswordUseCaseImpl: ResetMypagePasswordUseCase {
    private let repository: MypageUserRepository

    public init(repository: MypageUserRepository) {
        self.repository = repository
    }

    public func execute(loginId: String, newPassword: String) async throws {
        try await repository.updatePassword(loginId: loginId, prevPassword: "", newPassword: newPassword)
    }
}
