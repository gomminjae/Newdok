import Foundation
import Shared

public protocol CheckMypageIDDupUseCase: Sendable {
    func execute(_ loginId: String) async throws -> CheckResult<MypageSimpleUser>
}
