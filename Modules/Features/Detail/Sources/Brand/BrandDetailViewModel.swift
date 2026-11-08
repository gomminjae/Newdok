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
    let analyticsViewID = UUID()
    let analyticsSource: AnalyticsContentSource
    private(set) var articleList = AnalyticsListContext(.newsletterArticles)
    private var didViewDetail = false
    private(set) var subscriptionSession: SubscriptionAnalyticsSession?
    public let analytics: AnalyticsClient

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
        popupPreference: SubscribePopupStorable,
        userInfoStore: UserInfoStoreProtocol,
        source: AnalyticsContentSource = .unknown,
        analytics: AnalyticsClient = .disabled
    ) {
        self.analyticsSource = source
        self.analytics = analytics
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

    var requiresSpecialSubscribeFlow: Bool {
        detail?.brandId == 321
    }

    func hideSubscribeStatePopupForToday() {
        popupPreference.hideForToday()
    }

    func detailViewed() {
        guard !didViewDetail, !isLoading, let detail else { return }
        didViewDetail = true
        analytics.record(.newsletterDetailViewed(.init(id: String(detail.brandId), name: detail.brandName), viewID: analyticsViewID, source: analyticsSource, status: detail.subscriptionStatus.analyticsStatus), from: analyticsSource.entryPoint)
    }

    func startSubscription() -> Bool {
        guard let detail, subscriptionSession == nil else { return false }
        subscriptionSession = SubscriptionAnalyticsSession(newsletter: .init(id: String(detail.brandId), name: detail.brandName), url: detail.subscribeUrl, client: analytics, from: .newsletterDetail, viewID: analyticsViewID, status: detail.subscriptionStatus.analyticsStatus)
        return subscriptionSession != nil
    }

    func closeSubscription() {
        subscriptionSession?.pageClosed()
        subscriptionSession = nil
    }

    public func fetch() async { await load(guest: false) }
    public func guestFetch() async { await load(guest: true) }

    private func load(guest: Bool) async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            let response = try await (guest ? brandRepository.fetchGuestNewsletterBrand(id: id) : brandRepository.fetchNewsletterBrand(id: id))
            try Task.checkCancellation()
            detail = response
            articleList = .init(.newsletterArticles)
            currentError = nil
        } catch {
            guard !Task.isCancelled, !(error is CancellationError) else { return }
            analytics.record(.operationFailed(.newsletter(id: id, viewID: analyticsViewID), category: .init(error: error)), from: analyticsSource.entryPoint)
            handleError(error, feature: "brandDetail", operation: "fetch")
        }
    }

    public func resume() async -> Bool {
        guard !isSubscriptionMutating else { return false }
        isSubscriptionMutating = true
        defer { isSubscriptionMutating = false }

        do {
            try await brandRepository.resumeSubscription(newsletterId: id)
            currentError = nil
            detail?.subscriptionStatus = .confirmed
            return true
        } catch let error as DetailError {
            currentError = .userMessage(error.localizedDescription)
            return false
        } catch {
            handleError(error, feature: "brandDetail", operation: "resume")
            return false
        }
    }

    public func pause() async -> Bool {
        guard !isSubscriptionMutating else { return false }
        isSubscriptionMutating = true
        defer { isSubscriptionMutating = false }

        do {
            try await brandRepository.pauseSubscription(newsletterId: id)
            currentError = nil
            detail?.subscriptionStatus = .paused
            return true
        } catch let error as DetailError {
            currentError = .userMessage(error.localizedDescription)
            return false
        } catch {
            handleError(error, feature: "brandDetail", operation: "pause")
            return false
        }
    }
}

extension SubscriptionStatus {
    var analyticsStatus: AnalyticsSubscriptionStatus {
        switch self {
        case .initial: .initial
        case .check: .check
        case .confirmed: .confirmed
        case .paused: .paused
        case .unknown: .unknown
        }
    }
}
