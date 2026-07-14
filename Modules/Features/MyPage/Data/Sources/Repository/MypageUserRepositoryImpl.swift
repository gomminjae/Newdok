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

    public func updateInterest(_ interestsId: [Int]) async throws {
        try await network.requestVoid(UpdateInterest(interestsId: interestsId))
        updateLocalUser { $0.interestIds = interestsId }
    }

    public func updateIndustry(_ industryId: Int) async throws {
        try await network.requestVoid(UpdateIndustry(industryId: industryId))
        updateLocalUser { $0.industryId = industryId }
    }

    public func withdraw() async throws {
        try await network.requestVoid(Withdraw())
    }

    private func persistLocalUser(from user: MypageUser) {
        let userInfo = UserInfo(
            id: user.id,
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
