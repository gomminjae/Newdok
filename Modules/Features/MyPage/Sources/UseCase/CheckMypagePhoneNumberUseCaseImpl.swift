import MypageDomain
import Shared

public final class CheckMypagePhoneNumberUseCaseImpl: CheckMypagePhoneNumberUseCase {
    private let repository: MypageUserRepository

    public init(repository: MypageUserRepository) {
        self.repository = repository
    }

    public func execute(_ phoneNumber: String) async throws -> [MypageSimpleUser] {
        try await repository.checkPhoneNumber(phoneNumber)
    }
}
