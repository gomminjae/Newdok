import MypageDomain

public final class UpdateMypagePhoneNumberUseCaseImpl: UpdateMypagePhoneNumberUseCase {
    private let repository: MypageUserRepository

    public init(repository: MypageUserRepository) {
        self.repository = repository
    }

    public func execute(_ phoneNumber: String) async throws {
        try await repository.updatePhoneNumber(phoneNumber)
    }
}
