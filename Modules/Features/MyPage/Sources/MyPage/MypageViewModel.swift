//
//  MypageViewModel.swift
//  Mypage
//
//  Created by 권민재 on 5/9/25.
//  Copyright © 2025 Newdok. All rights reserved.
//

import Foundation
import MypageDomain
import Shared
import Observation
import UIKit

@Observable
@MainActor
public final class MypageViewModel: ErrorHandling {
    var activeNavigation: String?

    var nickname: String = ""
    public var user: MypageUser?
    private var localUserInfo: UserInfo?

    public var displayNickname: String {
        user?.nickname ?? localUserInfo?.nickname ?? ""
    }

    public var displaySubscribeEmail: String {
        user?.subscribeEmail ?? localUserInfo?.subscribeEmail ?? ""
    }

    var shownicknameToast: Bool = false
    var showIndustryToast: Bool = false
    var showInterestToast: Bool = false
    public var showNicknameSuccess: Bool = false
    public var showIndustrySuccess: Bool = false
    public var showInterestSuccess: Bool = false

    public var currentError: AppError?
    public var isNicknameUpdating: Bool = false
    public var isIndustryUpdating: Bool = false
    public var isInterestUpdating: Bool = false

    private let fetchProfileUseCase: FetchMypageProfileUseCase
    private let updateNicknameUseCase: UpdateMypageNicknameUseCase
    private let updateInterestsUseCase: UpdateMypageInterestsUseCase
    private let updateIndustryUseCase: UpdateMypageIndustryUseCase
    private let selectableItemStore: SelectableItemStoreProtocol
    private let userInfoStore: UserInfoStoreProtocol

    public init(
        fetchProfileUseCase: FetchMypageProfileUseCase,
        updateNicknameUseCase: UpdateMypageNicknameUseCase,
        updateInterestsUseCase: UpdateMypageInterestsUseCase,
        updateIndustryUseCase: UpdateMypageIndustryUseCase,
        selectableItemStore: SelectableItemStoreProtocol,
        userInfoStore: UserInfoStoreProtocol
    ) {
        self.fetchProfileUseCase = fetchProfileUseCase
        self.updateNicknameUseCase = updateNicknameUseCase
        self.updateInterestsUseCase = updateInterestsUseCase
        self.updateIndustryUseCase = updateIndustryUseCase
        self.selectableItemStore = selectableItemStore
        self.userInfoStore = userInfoStore
    }

    @discardableResult
    public func loadUserInfo() -> UserInfo? {
        let info = userInfoStore.load()
        localUserInfo = info
        return info
    }

    public func copySubscribeEmail() {
        UIPasteboard.general.string = displaySubscribeEmail
    }

    public func fetchuserInfo() async {
        await performAsync(feature: "mypage", operation: "fetchUserInfo") {
            user = try await fetchProfileUseCase.execute()
        }
    }

    public func updateNickname(nickname: String) async -> Bool {
        guard !isNicknameUpdating else { return false }
        isNicknameUpdating = true
        defer { isNicknameUpdating = false }

        let result: Void? = await performAsync(feature: "mypage", operation: "updateNickname") {
            try await updateNicknameUseCase.execute(nickname)

            // UI 상태 업데이트
            user = user?.with(nickname: nickname)

            showNicknameSuccess = true
        }
        return result != nil
    }

    public func updateIndustry(id: Int) async -> Bool {
        guard !isIndustryUpdating else { return false }
        isIndustryUpdating = true
        defer { isIndustryUpdating = false }

        let result: Void? = await performAsync(feature: "mypage", operation: "updateIndustry") {
            try await updateIndustryUseCase.execute(id)

            // UI 상태 업데이트
            user = user?.with(industryId: id)

            showIndustrySuccess = true
        }
        return result != nil
    }

    public func updateInterests(ids: [Int]) async -> Bool {
        guard !isInterestUpdating else { return false }
        isInterestUpdating = true
        defer { isInterestUpdating = false }

        let result: Void? = await performAsync(feature: "mypage", operation: "updateInterests") {
            try await updateInterestsUseCase.execute(ids)

            // UI 상태 업데이트
            let updatedInterests = ids.map { MypageInterest(id: $0, name: selectableItemStore.name(for: $0, in: .interest)) }
            user = user?.with(interests: updatedInterests)

            showInterestSuccess = true
        }
        return result != nil
    }

    func industryName(for id: Int) -> String {
        selectableItemStore.name(for: id, in: .industry)
    }

    func interestName(for id: Int) -> String {
        selectableItemStore.name(for: id, in: .interest)
    }

    var industries: [SelectableItem] {
        selectableItemStore.list(for: .industry)
    }

    var interests: [SelectableItem] {
        selectableItemStore.list(for: .interest)
    }
}
