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
    public var currentError: AppError?

    private let id: String
    private let brandRepository: DetailBrandRepository

    public init(id: String, brandRepository: DetailBrandRepository) {
        self.id = id
        self.brandRepository = brandRepository
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

    public func resume() async {
        await performAsync(feature: "brandDetail", operation: "resume") {
            try await brandRepository.resumeSubscription(newsletterId: id)
        }
    }

    public func pause() async {
        await performAsync(feature: "brandDetail", operation: "pause") {
            try await brandRepository.pauseSubscription(newsletterId: id)
        }
    }
}
