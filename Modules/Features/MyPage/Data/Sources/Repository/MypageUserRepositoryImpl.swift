import Foundation
import MypageDomain
import Core
import Shared

public final class MypageUserRepositoryImpl: MypageUserRepository {
    private let network: any NetworkService<UserAPI>

    public init(network: any NetworkService<UserAPI>) {
        self.network = network
    }

    public func getProfile() async throws -> MypageUser {
        let response: MypageUserDTO = try await network.request(.profile)
        let user = response.toDomain()
        persistLocalUser(from: user)
        return user
    }

    public func updateNickname(_ nickname: String) async throws -> MypageNicknameResponse {
        let response: MypageNicknameResponseDTO = try await network.request(.updateNickname(nickname: nickname))
        let result = response.toDomain()
        updateLocalUser { $0.withNickname(nickname) }
        return result
    }

    public func updatePassword(prevPassword: String, newPassword: String) async throws {
        guard let userInfo = UserInfoStore.shared.load() else {
            throw MypageProfileError.userNotFound
        }
        try await network.requestVoid(.updatePassword(loginId: userInfo.loginId, prevPassword: prevPassword, password: newPassword))
    }

    public func updatePassword(loginId: String, prevPassword: String, newPassword: String) async throws {
        try await network.requestVoid(.updatePassword(loginId: loginId, prevPassword: prevPassword, password: newPassword))
    }

    public func updateInterest(_ interestsId: [Int]) async throws {
        try await network.requestVoid(.updateInterest(interestsId: interestsId))
        updateLocalUser { $0.withInterestIds(interestsId) }
    }

    public func updateIndustry(_ industryId: Int) async throws {
        try await network.requestVoid(.updateIndustry(industryId: industryId))
        updateLocalUser { $0.withIndustryId(industryId) }
    }

    public func updatePhoneNumber(_ phoneNumber: String) async throws {
        try await network.requestVoid(.updatePhoneNumber(phoneNumber: phoneNumber))
    }

    public func authSMS(phoneNumber: String) async throws -> MypageSMSResponse {
        let response: MypageSMSResponseDTO = try await network.request(.authSMS(phoneNumber: phoneNumber))
        return response.toDomain()
    }

    public func checkPhoneNumber(_ phoneNumber: String) async throws -> [MypageSimpleUser] {
        do {
            let response: [MypageSimpleUserDTO] = try await network.request(.checkPhoneNumber(phoneNumber: phoneNumber))
            return response.compactMap { $0.toDomain() }
        } catch let error as NetworkError {
            if case .serverError(let statusCode, _) = error, statusCode == 400 {
                return []
            } else {
                throw error
            }
        } catch {
            throw error
        }
    }

    public func checkIDDup(_ loginId: String) async throws -> CheckResult<MypageSimpleUser> {
        let result = try await network.checkRequest(.checkIDDup(loginId: loginId), decodeTo: MypageSimpleUserDTO.self)
        switch result {
        case .exists(let dto):
            return .exists(dto.toDomain())
        case .notFound:
            return .notFound
        }
    }

    public func withdraw() async throws {
        try await network.requestVoid(.withdraw)
    }

    private func persistLocalUser(from user: MypageUser) {
        let userInfo = UserInfo(
            id: user.id,
            loginId: user.loginId,
            phoneNumber: user.phoneNumber,
            subscribeEmail: user.subscribeEmail,
            nickname: user.nickname,
            birthYear: user.birthYear,
            gender: user.gender,
            createdAt: user.createdAt,
            industryId: user.industryId,
            interestIds: user.interests.map { $0.id }
        )
        UserInfoStore.shared.save(userInfo)
    }

    private func updateLocalUser(_ transform: (UserInfo) -> UserInfo) {
        guard let userInfo = UserInfoStore.shared.load() else { return }
        UserInfoStore.shared.save(transform(userInfo))
    }
}
