//
//  BrandDetailViewModel.swift
//  Detail
//
//  Created by 권민재 on 5/11/25.
//

import Domain
import Foundation
import Combine


@MainActor
public final class BrandDetailViewModel: ObservableObject {
    @Published var detail: BrandDetail?
    @Published var isLoading: Bool = false

    private let id: String
    private let useCase: NewsletterUseCase

    public init(id: String, useCase: NewsletterUseCase) {
        self.id = id
        self.useCase = useCase
        
    }

    public func fetch() async {
        isLoading = true
        do {
            let data = try await useCase.fetchNewsletterBrand(id: id)
            detail = data
        } catch {
            print("BrandDetail fetch error:", error)
        }
        isLoading = false
    }
}
