import Foundation
import MypageDomain
import NetworkKit
import Shared

public final class MypageUserRepositoryImpl: MypageUserRepository {
    private let network: any NetworkService
    private let userInfoStore: UserInfoStoreProtocol

    public init(
        network: any NetworkService,
        userInfoStore: UserInfoStoreProtocol
    ) {
        self.network = network
        self.userInfoStore = userInfoStore
    }

    public func getProfile() async throws -> MypageUser {
        let response = try await network.request(FetchProfile())
        let user = response.toDomain()
        persistLocalUser(from: user)
        return user
    }

    public func updateNickname(_ nickname: String) async throws -> MypageNicknameResponse {
        let response = try await network.request(UpdateNickname(nickname: nickname))
        let result = response.toDomain()
        updateLocalUser { $0.nickname = nickname }
        return result
    }

    public func updatePassword(prevPassword: String, newPassword: String) async throws {
        guard let userInfo = userInfoStore.load() else {
            throw MypageProfileError.userNotFound
        }
        try await network.requestVoid(UpdatePassword(loginId: userInfo.loginId, prevPassword: prevPassword, password: newPassword))
    }

    public func updatePassword(loginId: String, prevPassword: String, newPassword: String) async throws {
        try await network.requestVoid(UpdatePassword(loginId: loginId, prevPassword: prevPassword, password: newPassword))
    }

    public func updateInterest(_ interestsId: [Int]) async throws {
        try await network.requestVoid(UpdateInterest(interestsId: interestsId))
        updateLocalUser { $0.interestIds = interestsId }
    }

    public func updateIndustry(_ industryId: Int) async throws {
        try await network.requestVoid(UpdateIndustry(industryId: industryId))
        updateLocalUser { $0.industryId = industryId }
    }

    public func updatePhoneNumber(_ phoneNumber: String) async throws {
        try await network.requestVoid(UpdatePhoneNumber(phoneNumber: phoneNumber))
    }

    public func authSMS(phoneNumber: String) async throws -> MypageSMSResponse {
        let response = try await network.request(AuthSMS(phoneNumber: phoneNumber))
        return response.toDomain()
    }

    public func checkPhoneNumber(_ phoneNumber: String) async throws -> [MypageSimpleUser] {
        do {
            let response = try await network.request(CheckPhoneNumber(phoneNumber: phoneNumber))
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

    public func checkIDDup(_ loginId: String) async throws -> MypageIDCheckResult {
        let result = try await network.checkRequest(CheckIDDup(loginId: loginId))
        switch result {
        case .exists(let dto):
            return .exists(dto.toDomain())
        case .notFound:
            return .notFound
        }
    }

    public func withdraw() async throws {
        try await network.requestVoid(Withdraw())
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
        userInfoStore.save(userInfo)
    }

    private func updateLocalUser(_ transform: (inout UserInfo) -> Void) {
        guard var userInfo = userInfoStore.load() else { return }
        transform(&userInfo)
        userInfoStore.save(userInfo)
    }
}
