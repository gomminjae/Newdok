import MypageDomain

public final class UpdateMypageNicknameUseCaseImpl: UpdateMypageNicknameUseCase {
    private let repository: MypageUserRepository

    public init(repository: MypageUserRepository) {
        self.repository = repository
    }

    public func execute(_ nickname: String) async throws {
        _ = try await repository.updateNickname(nickname)
    }
}
