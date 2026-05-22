//
//  BrandDetailViewModel.swift
//  Detail
//
//  Created by 권민재 on 5/11/25.
//

import DetailDomain
import Foundation
import Shared
import Observation

@Observable
@MainActor
public final class BrandDetailViewModel: ErrorHandling {
    var detail: DetailBrandDetail?
    var isLoading: Bool = false
    var isSubscriptionMutating: Bool = false
    public var currentError: AppError?

    private let id: String
    private let brandRepository: DetailBrandRepository
    private let popupPreference: SubscribePopupStorable
    private let userInfoStore: UserInfoStoreProtocol

    public init(
        id: String,
        brandRepository: DetailBrandRepository,
        popupPreference: SubscribePopupStorable = SubscribePopupPreference.shared,
        userInfoStore: UserInfoStoreProtocol = UserInfoStore.shared
    ) {
        self.id = id
        self.brandRepository = brandRepository
        self.popupPreference = popupPreference
        self.userInfoStore = userInfoStore
    }

    var subscribeEmail: String {
        userInfoStore.load()?.subscribeEmail ?? ""
    }

    var userNickname: String {
        userInfoStore.load()?.nickname ?? ""
    }

    var shouldShowSubscribeStatePopup: Bool {
        popupPreference.shouldShow
    }

    func hideSubscribeStatePopupForToday() {
        popupPreference.hideForToday()
    }

    public func fetch() async {
        await performAsync(feature: "brandDetail", operation: "fetch", loadingBinding: \.isLoading) {
            detail = try await brandRepository.fetchNewsletterBrand(id: id)
        }
    }

    public func guestFetch() async {
        await performAsync(feature: "brandDetail", operation: "guestFetch", loadingBinding: \.isLoading) {
            detail = try await brandRepository.fetchGuestNewsletterBrand(id: id)
        }
    }

    public func resume() async -> Bool {
        guard !isSubscriptionMutating else { return false }
        isSubscriptionMutating = true
        defer { isSubscriptionMutating = false }

        let result: Void? = await performAsync(feature: "brandDetail", operation: "resume") {
            try await brandRepository.resumeSubscription(newsletterId: id)
        }
        return result != nil
    }

    public func pause() async -> Bool {
        guard !isSubscriptionMutating else { return false }
        isSubscriptionMutating = true
        defer { isSubscriptionMutating = false }

        let result: Void? = await performAsync(feature: "brandDetail", operation: "pause") {
            try await brandRepository.pauseSubscription(newsletterId: id)
        }
        return result != nil
    }
}
