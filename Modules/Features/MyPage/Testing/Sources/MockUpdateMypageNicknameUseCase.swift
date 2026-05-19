import Foundation
import MypageDomain

public final class MockUpdateMypageNicknameUseCase: UpdateMypageNicknameUseCase {
    public var result: Result<Void, Error> = .success(())
    public private(set) var executedNickname: String?

    public init() {}

    public func execute(_ nickname: String) async throws {
        executedNickname = nickname
        try result.get()
    }
}
