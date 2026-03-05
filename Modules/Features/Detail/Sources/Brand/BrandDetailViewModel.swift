//
//  BrandDetailViewModel.swift
//  Detail
//
//  Created by 권민재 on 5/11/25.
//

import Domain
import Foundation
import Combine
import Shared

@MainActor
public final class BrandDetailViewModel: ObservableObject, ErrorHandling {
    @Published var detail: BrandDetail?
    @Published var isLoading: Bool = false
    @Published public var currentError: AppError?

    private let id: String
    private let useCase: NewsletterUseCase

    public init(id: String, useCase: NewsletterUseCase) {
        self.id = id
        self.useCase = useCase
    }

    public func fetch() async {
        await performAsync(feature: "brandDetail", operation: "fetch", loadingBinding: \.isLoading) {
            detail = try await useCase.fetchNewsletterBrand(id: id)
        }
    }

    public func guestFetch() async {
        await performAsync(feature: "brandDetail", operation: "guestFetch", loadingBinding: \.isLoading) {
            detail = try await useCase.fetchGuestNewsletterBrand(id: id)
        }
    }

    public func resume() async {
        await performAsync(feature: "brandDetail", operation: "resume") {
            _ = try await useCase.resumeSubscription(newsletterId: id)
        }
    }

    public func pause() async {
        await performAsync(feature: "brandDetail", operation: "pause") {
            _ = try await useCase.pauseSubscription(newsletterId: id)
        }
    }
}
