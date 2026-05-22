import Foundation

public protocol CheckMypagePhoneNumberUseCase: Sendable {
    func execute(_ phoneNumber: String) async throws -> [MypageSimpleUser]
}
