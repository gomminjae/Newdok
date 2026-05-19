import Foundation

public protocol UpdateMypagePhoneNumberUseCase: Sendable {
    func execute(_ phoneNumber: String) async throws
}
