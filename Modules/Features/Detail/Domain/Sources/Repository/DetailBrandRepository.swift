//
//  DetailBrandRepository.swift
//  DetailDomain
//

public protocol DetailBrandRepository {
    func fetchNewsletterBrand(id: String) async throws -> DetailBrandDetail
    func fetchGuestNewsletterBrand(id: String) async throws -> DetailBrandDetail
    func pauseSubscription(newsletterId: String) async throws
    func resumeSubscription(newsletterId: String) async throws
}
