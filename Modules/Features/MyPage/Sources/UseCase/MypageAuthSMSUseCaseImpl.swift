import MypageDomain
import Shared

public final class MypageAuthSMSUseCaseImpl: MypageAuthSMSUseCase {
    private let repository: MypageUserRepository

    public init(repository: MypageUserRepository) {
        self.repository = repository
    }

    public func execute(phoneNumber: String) async throws -> MypageSMSResponse {
        try await repository.authSMS(phoneNumber: phoneNumber)
    }
}
