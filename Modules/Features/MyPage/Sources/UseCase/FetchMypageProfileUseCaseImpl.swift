import MypageDomain
import Shared

public final class FetchMypageProfileUseCaseImpl: FetchMypageProfileUseCase {
    private let repository: MypageUserRepository

    public init(repository: MypageUserRepository) {
        self.repository = repository
    }

    public func execute() async throws -> MypageUser {
        try await repository.getProfile()
    }
}
