import MypageDomain

public final class UpdateMypagePasswordUseCaseImpl: UpdateMypagePasswordUseCase {
    private let repository: MypageUserRepository

    public init(repository: MypageUserRepository) {
        self.repository = repository
    }

    public func execute(prevPassword: String, newPassword: String) async throws {
        try await repository.updatePassword(prevPassword: prevPassword, newPassword: newPassword)
    }
}
