import Foundation

public protocol MypageWithdrawUseCase: Sendable {
    func execute() async throws
}
